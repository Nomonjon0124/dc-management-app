# Meeting integratsiyasi: mobile, web va backend auditi

Sana: 2026-09-23
Scope: `dc_management_app` (Flutter mobile), `dc-management-frontend` (React web), `dc-management-backend` (Django/Channels/LiveKit)

## 1. Audit xulosasi

Meeting funksiyasi uchta qatlamga bo‘lingan:

```text
REST API
  ├─ meeting CRUD, close, admit
  ├─ meeting-attendance va absence reason
  └─ WebSocket ticket

Django Channels meeting WebSocket
  ├─ meeting_state
  ├─ waiting room / knock / admit
  ├─ token_response
  └─ meeting_ended

LiveKit
  ├─ audio/video/screen share
  └─ Data Channel: chat, hand raise, reaction
```

Hozirgi holatda asosiy meeting lifecycle web va mobile’da backend kontraktiga yaqin ishlaydi. Ammo quyidagi sabablar tufayli ular bir xil ishlamaydi:

1. Web moderator funksiyalari (`mute`, `camera off`, `ask unmute`) backend orqali emas, client yuborgan LiveKit Data Channel xabarlari orqali bajariladi. Bu authorization emas: oddiy participant ham xuddi shu xabarni spoof qila oladi.
2. Mobile bu web moderation xabarlarini parse qilmaydi. Web’dan mobile participantni boshqarish, mobile’dan web participantni boshqarish ishlamaydi.
3. Web va mobile Data Channel message formatlari bir xil emas: `raise_hand` va `hand_raise`, `emoji` va `reaction`, `time` va `sent_at` kabi tafovutlar bor.
4. Web meeting WebSocket URL’i production `.env`dagi `https://.../api` qiymatidan bevosita yasalmoqda; `WebSocket` uchun `wss://...` kerak.
5. Backend `admit` action’ida target user shu meeting qatnashchisi ekanini tekshirmaydi. Arbitrary user uchun meeting LiveKit tokeni yaratilishi mumkin.
6. Web `admit`ni bir vaqtning o‘zida WebSocket va REST orqali yuboradi. Natijada ikki marta token/event kelishi mumkin.
7. Ticket middleware meeting ticket’ini birinchi ishlatilgandan keyin consume qilmaydi. Hujjatdagi “one-time ticket” talabi amalda to‘liq bajarilmagan.

### Yakuniy qaror

Backend meeting lifecycle’ning yagona authorization manbai bo‘lishi kerak. Quyidagilarni backend talab qiladi:

- join/admit/token flow’ni saqlash va validation’ni mustahkamlash;
- moderation action’larini meeting WebSocket’ga ko‘chirish;
- LiveKit Room Service’ni faqat backendda ishlatish;
- web va mobile uchun bitta Data Channel protokolini belgilash;
- attendance/absence reason kontraktini web va mobile’da tenglashtirish;
- production WebSocket, LiveKit, webhook va firewall sozlamalarini verifikatsiya qilish.

Chat, hand raise va reaction uchun hozircha database yoki REST persistence shart emas. Ular LiveKit Data Channel orqali ephemeral bo‘lib qolishi mumkin. Lekin message schema web va mobile uchun bir xil bo‘lishi shart.

## 2. Audit manbalari va snapshot

Audit kodning 2026-09-23 holatidagi snapshot’i bo‘yicha bajarildi.

| Qism | Manba | Snapshot |
|---|---|---|
| Mobile | lokal `dc-management-app` | `eca36cc73898ba7820b3d1747b69392f6183a0e7` |
| Web | `raqamli-nazorat/dc-management-frontend` | `49796be1e6971b7f1c2e9867aa70c0a7dcd5aa29` |
| Backend | `raqamli-nazorat/dc-management-backend` | `97970f4763a6172bf7c386d3ad517cde5ede9a26` |
| Existing docs | `docs/meetings.md`, `docs/livekit_meeting_integration_analysis.md`, old `docs/backend-report.md` | lokal repo |

Asosiy kod manbalari:

- [Backend MeetingConsumer](https://github.com/raqamli-nazorat/dc-management-backend/blob/97970f4763a6172bf7c386d3ad517cde5ede9a26/apps/projects/consumers.py)
- [Backend LiveKitService](https://github.com/raqamli-nazorat/dc-management-backend/blob/97970f4763a6172bf7c386d3ad517cde5ede9a26/apps/projects/services.py)
- [Backend meeting views](https://github.com/raqamli-nazorat/dc-management-backend/blob/97970f4763a6172bf7c386d3ad517cde5ede9a26/apps/projects/views.py)
- [Backend meeting models/serializers](https://github.com/raqamli-nazorat/dc-management-backend/blob/97970f4763a6172bf7c386d3ad517cde5ede9a26/apps/projects/models.py)
- [Web MeetingRoom](https://github.com/raqamli-nazorat/dc-management-frontend/blob/49796be1e6971b7f1c2e9867aa70c0a7dcd5aa29/src/pages/MeetingRoom/MeetingRoom.jsx)
- [Web meeting modals](https://github.com/raqamli-nazorat/dc-management-frontend/blob/49796be1e6971b7f1c2e9867aa70c0a7dcd5aa29/src/components/MeetingModals.jsx)

## 3. Hozirgi ishlayotgan kontrakt

### 3.1 Meeting REST API

Backend `config/urls.py` orqali barcha API’ni `/api/` ostida expose qiladi.

| Method | Endpoint | Vazifa | Mobile | Web |
|---|---|---|---|---|
| `GET` | `/api/meetings/` | ro‘yxat, filter, pagination | ishlatiladi | ishlatiladi |
| `POST` | `/api/meetings/` | meeting yaratish | ishlatiladi | ishlatiladi |
| `GET` | `/api/meetings/{id}/` | detail | ishlatiladi | ishlatiladi |
| `PUT/PATCH` | `/api/meetings/{id}/` | tahrirlash | ishlatiladi | ishlatiladi |
| `DELETE` | `/api/meetings/{id}/` | soft delete | ishlatiladi | ishlatiladi |
| `POST` | `/api/meetings/{id}/close/` | hammaga meeting tugadi | ishlatiladi | ishlatiladi |
| `POST` | `/api/meetings/{id}/admit/` | admit/reject REST fallback | mavjud | web’da qo‘shimcha fallback |
| `GET` | `/api/meeting-attendance/?meeting={id}` | attendance list | ishlatiladi | ishlatiladi |
| `GET` | `/api/meeting-attendance/{id}/` | bitta attendance | ishlatiladi | ishlatiladi |
| `PATCH` | `/api/meeting-attendance/{id}/` | attendance, reason, excuse | ishlatiladi | ishlatiladi |
| `POST` | `/api/notifications/tickets/` | 60 sekundlik WS ticket | ishlatiladi | ishlatiladi |
| `POST` | `/api/meetings/livekit/webhook/` | LiveKit eventlarini attendance’ga yozish | backend | backend |

### 3.2 Meeting serializer contract’i

`MeetingSerializer` quyidagi asosiy field’larni qaytaradi:

```json
{
  "id": 16,
  "uid": "MT-0009",
  "room_name": "MT-0009",
  "project": 4,
  "organizer": 45,
  "title": "Haftalik tahlil",
  "description": "...",
  "recording_url": null,
  "requires_approval": true,
  "penalty_percentage": "0.50",
  "start_time": "2026-09-23T10:00:00+05:00",
  "duration_minutes": 30,
  "is_completed": false,
  "participants_info": [
    {"id": 45, "username": "Ali", "position": "Manager", "avatar": "..."}
  ]
}
```

`participants` write-only ID ro‘yxati, javobda esa `participants_info` keladi. Backend meeting link’ni clientdan olmaydi; `uid` va LiveKit `room_name` serverda yaratiladi.

### 3.3 Meeting WebSocket

Ticket olingandan keyin ulanish:

```text
wss://backend.raqamlinazorat.uz/api/ws/meetings/{meeting_id}/?ticket={ticket}
```

Backend routing `ws/meetings/{id}` va `api/ws/meetings/{id}` variantlarini qabul qiladi.

Mavjud client → server action’lari:

```json
{"action":"ask_to_join"}
{"action":"admit","user_id":45,"decision":"approve"}
{"action":"admit","user_id":45,"decision":"reject"}
{"action":"get_token","device_id":"phone-1","device_name":"Telefon"}
```

Mavjud server → client event’lari:

- `meeting_state`
- `waiting_organizer`
- `organizer_joined`
- `knock_request`
- `knock_response`
- `token_response`
- `meeting_ended`
- `error`

`meeting_state`ning asosiy ko‘rinishi:

```json
{
  "type": "meeting_state",
  "meeting_id": 16,
  "title": "Haftalik tahlil",
  "requires_approval": true,
  "organizer_joined": true,
  "is_host": true,
  "is_approved": true,
  "token": "<jwt yoki null>",
  "server_url": "wss://livekit.example.com",
  "room_name": "MT-0009"
}
```

Join flow:

```text
ticket
  -> meeting WebSocket
  -> meeting_state
  -> organizer hali kirmagan bo‘lsa waiting_organizer
  -> approval kerak bo‘lsa ask_to_join / waiting_approval
  -> host admit qiladi
  -> token_response
  -> LiveKit Room.connect()
```

### 3.4 LiveKit token

Backend tokenida hozir quyidagilar bor:

```text
room_join = true
can_publish = true
can_subscribe = true
can_publish_data = true
```

Host/co-host uchun qo‘shimcha:

```text
room_create = true
room_admin = true
room_record = true
```

Identity hozir `user_id + random/device suffix` shaklida yaratiladi:

```text
45_ab12cd
```

Metadata’da `user_id`, `username`, `full_name`, `device_id`, `is_organizer` mavjud. Attendance webhook shu identity’ning `_`dan oldingi qismini user ID deb o‘qiydi va multi-device active identity’larini cache’da saqlaydi.

Bu identity modeli ishlashi uchun mobile va web participant mapper’lari metadata’ni bir xil o‘qishi kerak. Faqat identity string’ni heuristik match qilish yetarli emas.

## 4. Mobile audit

### 4.1 Yaxshi ishlangan qismlar

Mobile’da meeting production oqimi BLoC orqali ajratilgan:

- `MeetingRealtimeDataSource` ticket oladi va meeting-specific WS ochadi;
- har reconnect’da yangi ticket olinadi;
- reconnect backoff 2 sekunddan 30 sekundgacha oshadi;
- `MeetingRoomBloc` WS eventlarini UI state’lariga map qiladi;
- `LiveKitMediaService` media, device, screen share va Data Channel’ni ajratadi;
- `MeetingRoomPage` UI sifatida qoladi, backend qarorini o‘zi yasamaydi;
- close/dispose paytida LiveKit va WS yopiladi;
- attendance reason alohida `/meeting-attendance/{id}/`ga yuboriladi;
- `ResponseMapper` pagination/envelope javoblarini ochadi.

Asosiy fayllar:

- `lib/features/meetings/data/data_sources/meeting_realtime_data_source.dart`
- `lib/features/meetings/data/services/livekit_media_service.dart`
- `lib/features/meetings/presentation/bloc/meeting_room_bloc.dart`
- `lib/features/meetings/presentation/pages/meeting_room_page.dart`

### 4.2 Mobile’da backend bilan bog‘liq kamchiliklar

#### M1 — Moderation production flow mavjud emas

`MeetingRoomRepository`, `MeetingRoomBloc` va `LiveKitMediaService`da moderatorning remote mic/camera mute yoki unmute request action’lari yo‘q. Faqat join approval (`admit`) mavjud.

Natija: web moderatori mobile participantni boshqara olmaydi; mobile moderatori ham web participantni boshqara olmaydi.

#### M2 — Attendance model late field’larini to‘liq olib yurmaydi

Backend `late_minutes`, `joined_at`, `left_at`, `duration_minutes` qaytaradi, lekin mobile `MeetingAttendance` faqat attended/excused/reason va user ma’lumotlarini saqlaydi. Shu sabab mobile late meeting reason’ni web kabi ko‘rsata olmaydi.

#### M3 — Organizer excuse list faqat `is_attended=false`

`MeetingReasonBloc` organizer rows’ni faqat qatnashmaganlar bilan to‘ldiradi. Backend esa `late_minutes > 5` bo‘lgan qatnashgan xodimga ham `absence_reason` yuborish va `is_excused` bilan baholashni qo‘llaydi. Mobile’da kechikish sababi review flow yetishmaydi.

#### M4 — Mobile route faqat numeric ID

`MeetingRoomPage` route parameter’ini `int.tryParse` qiladi. Web esa `MT-0009` UID link’ini ham qo‘llashga urinadi. Bir xil share link mobile’da to‘g‘ridan-to‘g‘ri ochilmaydi. Umumiy deep-link contract’ida UID → numeric ID resolve qilish kerak.

#### M5 — Terminal WebSocket error’da reconnect loop

Mobile data source `onDone` va socket error’ni umumiy reconnect sifatida ko‘radi. Backend `4003` (unauthorized/forbidden) yoki `4004` (meeting tugagan/topilmagan) yuborganda reconnect to‘xtashi va UI terminal state’ga o‘tishi kerak.

#### M6 — Mobile requestToken device metadata yubormaydi

Backend `device_id` va `device_name`ni qabul qiladi, lekin mobile `requestToken()` hozir faqat `{action: get_token}` yuboradi. Random suffix ishlaydi, ammo device label va multi-device UX bir xil bo‘lmaydi.

#### M7 — Participant identity mapping zaif

Backend identity `45_ab12cd`, mobile avatar mapping esa ko‘p joyda identity’ni to‘liq user ID bilan solishtiradi. Backend metadata’dan `user_id`ni domain participant’ga chiqarish va UI’da user ID/device ID’ni alohida saqlash kerak.

#### M8 — Data Channel parser lenient emas va schema web bilan farq qiladi

Mobile parser `jsonDecode` bilan faqat `chat`, `hand_raise`, `reaction`ni qabul qiladi. Web esa `raise_hand`, `reaction.emoji`, `chat.time` kabi boshqa payload yuboradi. Bu cross-platform real-time parity’ni buzadi.

## 5. Web audit

### 5.1 Web’da backend bilan ishlayotgan qismlar

Web quyidagilarni REST/API orqali bajaradi:

- meeting list, filter va pagination;
- meeting create/update/delete/restore/close;
- project va participant tanlash;
- meeting detail va attendance list;
- absence reason yuborish;
- attendance `is_attended` va `is_excused` update;
- join approval uchun meeting WS;
- LiveKit token olish va room’ga ulanish;
- Firebase/global notification oqimi.

### 5.2 Web’da backend’siz yoki noto‘g‘ri backendga ulangan qismlar

#### W1 — Moderator mute client-side Data Channel’da

Web quyidagi xabarlarni LiveKit Data Channel orqali yuboradi:

```json
{"type":"mute_participant","targetUserId":"45_ab12cd"}
{"type":"turn_off_camera","targetUserId":"45_ab12cd"}
{"type":"ask_unmute","targetUserId":"45_ab12cd"}
{"type":"ask_turn_on_camera","targetUserId":"45_ab12cd"}
```

Target client bu xabarni o‘zi ishonib qabul qiladi va local track’ni o‘chiradi. Sender nomi va `isLocalHost` client state’dan keladi. Oddiy participant browser console yoki custom LiveKit client orqali xuddi shu payload’ni yubora oladi.

Bu production authorization emas. Backend action/event protokoliga o‘tkazish majburiy.

#### W2 — Web localStorage chat history server history emas

Web `meeting_chat_{id}` orqali chatni localStorage’da saqlaydi. Bu:

- boshqa qurilmaga o‘tmaydi;
- mobile’da ko‘rinmaydi;
- browser storage tozalansa yo‘qoladi;
- meeting tugagandan keyin “history”dek ko‘rinishi mumkin.

Hozircha chat persistence kerak bo‘lmasa, meeting tugaganda local cache’ni tozalash va UI’da bu history emasligini aniq tutish kerak. Haqiqiy history kerak bo‘lsa alohida backend model/API talab qilinadi.

#### W3 — Web meeting WS scheme xatosi

Web `.env`:

```env
VITE_BASE_URL=https://backend.raqamlinazorat.uz/api
```

Ammo `MeetingRoom.jsx`:

```js
const wsUrl = `${rawBase}/ws/meetings/${meetingId}/?ticket=${ticket}`
new WebSocket(wsUrl)
```

Natija `https://.../api/ws/...` bo‘ladi. To‘g‘ri qiymat `wss://backend.raqamlinazorat.uz/api/ws/...` bo‘lishi kerak. Web helper HTTP(S) → WS(S) conversion’ni bitta umumiy function orqali bajarishi kerak.

#### W4 — Web global notification ticket parsing backend javobiga mos emas

Backend ticket endpoint direct body qaytaradi:

```json
{"ticket":"...","expires_in":60}
```

Web `Layout.jsx` esa `data.data.ticket`ni o‘qiydi. `data.ticket` fallback yo‘q. Shu sabab global notification socket ulanmasligi mumkin. Bundan tashqari notification WS host’i `locale.alijonov.uz` qilib hardcode qilingan, web `.env` host’i esa `backend.raqamlinazorat.uz`.

#### W5 — Web admit ikki marta yuboriladi

`handleAdmitUser` va `handleRejectUser` bir action’ni:

1. meeting WebSocket orqali;
2. `/meetings/{id}/admit/` REST orqali

yuboradi. Backend ikkala request’ni ham bajaradi. Approve holatida ikki token va ikki `knock_response` kelishi mumkin. Bitta transport tanlanishi kerak; tavsiya: WS’ni qoldirish, REST endpoint’ni admin/debug yoki backward compatibility uchun idempotent qilish.

#### W6 — UID deep-link backend search bilan mos emas

Web `MeetingRoom` numeric ID bo‘lmasa `/meetings/?search={uid}` qiladi. Backend `MeetingViewSet.search_fields` faqat `title` va `description`; `uid` search field emas. Demak `/meetings/mt-0009` direct refresh yoki boshqa browser’da meeting topilmasligi mumkin. Backendda `uid` bo‘yicha exact query/filter qo‘shish kerak.

#### W7 — Web attendance expiry clientda noto‘g‘ri hisoblanadi

Web absence formasi 24 soatni meeting `start_time`dan hisoblaydi. Backend attended user uchun `joined_at`, absent user uchun `completed_at`/`start_time`dan hisoblaydi. Client oldindan “muddati tugagan” yoki “hali mumkin” deb noto‘g‘ri ko‘rsatishi mumkin. Final qaror backendda qolishi, response’da `reason_deadline` yoki `can_submit_reason` kabi computed field qaytishi kerak.

#### W8 — Web attendance detail field’lari to‘liq emas

Web `AttendanceExcuseModal` `meeting_start_time`ni kutadi, ammo `MeetingAttendanceSerializer` hozir bu field’ni qaytarmaydi. UI sana bo‘sh ko‘rinishi mumkin. Serializerga kerakli read-only meeting summary field’lari yoki frontendga alohida meeting detail contract’i berilsin.

## 6. Backend audit

### 6.1 Mavjud ijobiy qismlar

- WebSocket access ticket orqali user aniqlanadi.
- Meeting socket connect paytida meeting active/completed va membership tekshiriladi.
- Host qoidasi organizer yoki meeting participant bo‘lgan admin/project manager sifatida markazlashtirilgan.
- `requires_approval` va organizer joined flow backendda mavjud.
- LiveKit webhook participant joined/left va room finished eventlarini attendance’ga yozadi.
- Multi-device active identities cache’da kuzatiladi.
- Meeting close `meeting_ended` eventini barcha socket participantlarga yuboradi.
- Absence reason `MeetingAttendance`, meeting emas, to‘g‘ri resource’ga yoziladi.
- LiveKit API key/secret backend settings’da qoladi; bu to‘g‘ri yo‘nalish.

### 6.2 Critical backend findings

#### B1 — `admit` target membership tekshirilmaydi (P0)

`MeetingConsumer.handle_admit` va REST `admit_participant` `target_user_id`ni oladi, lekin target user:

- meeting `participants` ichidami;
- meeting organizer’mi;
- haqiqatan knock yuborganmi;
- shu meeting socket’iga ulanganmi

ekanini to‘liq tekshirmaydi. Approve’da `LiveKitService.generate_token(target_user, meeting)` chaqiriladi. `generate_token` ham membershipni enforce qilmaydi, faqat token grant’ini hisoblaydi.

Tuzatish:

- target user meeting organizer yoki `MeetingAttendance` participant bo‘lishi shart;
- pending join request server-side cache/model’da mavjud bo‘lishi shart;
- target request yuborgan socket/session bilan bog‘lanishi shart;
- target online bo‘lmasa approve token event yuborilmasin;
- `generate_token` entry point’ida ham membership invariant saqlansin.

#### B2 — WebSocket action’lar uchun structured error yo‘q (P1)

Unknown action yoki unauthorized `admit` holatida ba’zan oddiy `{"error":"..."}` qaytadi. Barcha xatolar bitta formatda bo‘lishi kerak:

```json
{
  "type": "error",
  "code": "not_allowed",
  "message": "Faqat meeting mezboni ruxsat bera oladi.",
  "request_id": "uuid yoki null"
}
```

Bu mobile/web BLoC/state machine’ga transportdan mustaqil ishlash imkonini beradi.

#### B3 — Ticket “one-time” emas (P1)

`TicketAuthMiddleware` cache’dan ticketni o‘qiydi, lekin meeting socket muvaffaqiyatli authenticate bo‘lganda cache key’ni o‘chirmaydi. Notification consumer o‘z ticketini connection’dan keyin o‘chiradi, lekin meeting consumer buni qilmaydi.

Tuzatish variantlari:

- ticket type/consumer maqsadini (`notifications` yoki `meeting`) ticket yaratishda yozish;
- `cache.get` o‘rniga atomic `get-and-delete` ishlatish;
- meeting socket connect’da ticketni faqat successful membership tekshiruvdan keyin consume qilish;
- reconnect’da yangi ticket olish.

#### B4 — Host client tokeniga ortiqcha grant berilgan (P1)

Host/co-host client JWT’sida `room_admin`, `room_record`, `room_create` bor. Moderator action’lari backend Room Service orqali bajarilishi kerak bo‘lsa, mobil/web clientga bu grantlar kerak emas. Minimal client token:

```text
room_join
can_publish
can_subscribe
can_publish_data
```

Backendning server-side Room Service credential’i alohida qoladi va hech qachon APK/IPA/browser clientga berilmaydi.

#### B5 — Meeting lifecycle state backendda to‘liq finite-state emas (P1)

`ask_to_join` har safar yuborilsa pending request server-side deduplicate qilinmaydi. `admit` pending request mavjudligini ham tekshirmaydi. `meeting_ended`, expired request, duplicate approve/reject va user disconnect holatlari explicit state bilan boshqarilishi kerak.

#### B6 — Organizer group duplicate event olishi mumkin (P2)

Organizer host group’ga ham, organizer user group’ga ham qo‘shiladi. `ask_to_join` ikkala group’ga yuboriladi. Client deduplicate qilayotgan bo‘lsa ham, backend bitta recipientga ikki event yubormasligi ma’qul.

#### B7 — LiveKit URL va deployment hali contract sifatida verifikatsiya qilinmagan (P1)

Backend default `wss://livekit.example.com` ishlatishi mumkin. Production’da:

- `LIVEKIT_URL` haqiqiy `wss://` URL bo‘lishi;
- Nginx `/rtc/` yoki LiveKit signaling path’ini proxy qilishi;
- Django `/ws/` va `/api/ws/` path’lari Daphne/ASGI’ga borishi;
- TCP `7881` va UDP `50000-60000` ochiq bo‘lishi;
- `LIVEKIT_INTERNAL_URL` Room Service uchun ichki HTTP URL bo‘lishi;
- webhook URL va API key bir xil LiveKit deployment’ga tegishli bo‘lishi

real serverda tekshirilishi kerak.

#### B8 — Backend test coverage meeting uchun yetarli emas (P0/P1)

Backend repository’da meeting consumer/moderation/security flow uchun alohida to‘liq test suite ko‘rinmadi. Quyidagi testlar majburiy:

- begona user meeting socket’iga kira olmaydi;
- completed/inactive meeting reject qiladi;
- organizer, participant-admin va project manager host bo‘ladi;
- oddiy participant `admit` qila olmaydi;
- target meeting participant bo‘lmasa approve ishlamaydi;
- pending request bo‘lmasa approve ishlamaydi;
- duplicate approve idempotent;
- rejected/expired request qayta ishlamaydi;
- ticket ikkinchi meeting connection’da ishlamaydi;
- meeting tugagach barcha moderation/token action bloklanadi;
- multi-device join/leave attendance’ni noto‘g‘ri yopmaydi;
- webhook signature invalid bo‘lsa qabul qilinmaydi.

## 7. Web/mobile uchun yagona target kontrakt

### 7.1 Moderation WebSocket action’lari

Client faqat backend orchestration WS’ga quyidagilarni yuboradi:

```json
{
  "action": "moderate_track",
  "request_id": "uuid",
  "target_identity": "45_ab12cd",
  "track_source": "microphone",
  "operation": "mute"
}
```

Allowed qiymatlar:

```text
track_source: microphone | camera
operation: mute
```

Backend tekshiradi:

- requester shu meeting participantimi;
- requester organizer yoki backend `is_host=true` co-hostmi;
- target identity ayni room’da bormi;
- target identity shu meeting user’iga tegishlimi;
- target’da kerakli published track bormi;
- meeting tugamaganmi.

Backend LiveKit Room Service orqali mute qiladi va barcha participantlarga event yuboradi:

```json
{
  "type": "track_moderation_changed",
  "meeting_id": 16,
  "request_id": "uuid",
  "target_identity": "45_ab12cd",
  "user_id": 45,
  "track_source": "microphone",
  "muted": true,
  "actor_identity": "1_host123",
  "changed_at": "2026-09-23T10:30:00Z"
}
```

Failure:

```json
{
  "type": "moderation_error",
  "request_id": "uuid",
  "code": "track_not_published",
  "message": "Ishtirokchida faol mikrofon track mavjud emas."
}
```

Tavsiya error code’lari:

```text
not_allowed
participant_not_found
track_not_published
meeting_ended
request_expired
livekit_error
invalid_request
```

### 7.2 Unmute request

Moderator user’ning roziligisiz remote unmute qilmaydi:

```json
{
  "action": "request_track_unmute",
  "request_id": "uuid",
  "target_identity": "45_ab12cd",
  "track_source": "microphone",
  "expires_in": 30
}
```

Targetga:

```json
{
  "type": "track_unmute_requested",
  "request_id": "uuid",
  "from_identity": "1_host123",
  "from_name": "Organizer",
  "track_source": "microphone",
  "expires_at": "2026-09-23T10:30:30Z"
}
```

Target javobi:

```json
{
  "action": "respond_track_unmute_request",
  "request_id": "uuid",
  "decision": "accept"
}
```

Backend barcha kerakli tomonlarga natija yuboradi:

```json
{
  "type": "track_unmute_request_result",
  "request_id": "uuid",
  "target_identity": "45_ab12cd",
  "track_source": "microphone",
  "decision": "accepted",
  "changed_at": "2026-09-23T10:30:20Z"
}
```

Acceptdan keyin target client o‘z local track’ini `setMicrophoneEnabled(true)` yoki `setCameraEnabled(true)` bilan yoqadi. Backend avtomatik remote unmute qilmaydi.

### 7.3 Data Channel common schema

Chat, hand raise va reaction persistence’siz LiveKit Data Channel’da qoladi. Web va mobile quyidagi schema’dan foydalanishi kerak:

```json
{
  "version": 1,
  "type": "chat | hand_raise | reaction",
  "message_id": "uuid",
  "sender_identity": "45_ab12cd",
  "sender_name": "Ali Valiyev",
  "sent_at": "2026-09-23T10:30:00Z",
  "text": "Salom",
  "raised": true,
  "reaction": "👏"
}
```

Field’lar type’ga qarab:

| Type | Majburiy | Izoh |
|---|---|---|
| `chat` | `message_id`, sender, `sent_at`, `text` | reliable packet |
| `hand_raise` | `message_id`, sender, `sent_at`, `raised` | reliable packet |
| `reaction` | `message_id`, sender, `sent_at`, `reaction` | unreliable packet mumkin |

Eski web nomlari (`raise_hand`, `emoji`, `sender`, `time`) yangi mobile/web release’larda yuborilmasin. Backward compatibility uchun parser bir release davomida alias’larni o‘qishi mumkin, lekin yangi payload faqat canonical schema’da bo‘lsin.

### 7.4 Participant identity schema

LiveKit participant metadata’dan quyidagilar olinishi va mobile/web domain model’iga chiqarilishi kerak:

```json
{
  "user_id": 45,
  "username": "ali",
  "full_name": "Ali Valiyev",
  "device_id": "phone-1",
  "is_organizer": false
}
```

UI uchun:

- `identity`: track/session’ning unique ID’si;
- `user_id`: authorization/avatar/role uchun canonical ID;
- `device_id`: multi-device label uchun;
- `is_host`: faqat backend `meeting_state` yoki server event’dan.

Client identity prefix/suffix yoki display name orqali authorization qilmasin.

## 8. Attendance va absence reason parity

### 8.1 Backendning final qoidalari

- `MeetingAttendance` meeting qatnashuvining source of truth’i.
- User absence yoki kechikish sababini shu attendance ID’ga PATCH qiladi.
- `absence_reason` kamida 10 belgi.
- O‘z vaqtida qatnashgan user sabab yubora olmaydi.
- Attended user uchun deadline `joined_at + 24 soat`.
- Absent user uchun deadline `completed_at + 24 soat` yoki backend fallback qoidasi.
- Organizer/manager/admin `is_excused`ni o‘zgartira oladi.
- User o‘z sababini bir marta yuboradi; keyin o‘zgartira olmaydi.

### 8.2 Tavsiya etilgan response qo‘shimchalari

Web va mobile client-side vaqt hisoblashiga suyanmasligi uchun attendance response’iga quyidagilar read-only qo‘shilsin:

```json
{
  "late_minutes": 12,
  "joined_at": "...",
  "left_at": "...",
  "duration_minutes": 18,
  "reason_deadline": "2026-09-24T10:30:00+05:00",
  "can_submit_reason": true,
  "reason_status": "missing | submitted | accepted | rejected"
}
```

Shunda web va mobile aynan bitta backend qarorini ko‘rsatadi.

### 8.3 Mobile parity ishlari

- `MeetingAttendance`ga `lateMinutes`, `joinedAt`, `leftAt`, `durationMinutes` qo‘shish;
- organizer rows’ga `!isAttended || lateMinutes > 5` shartini qo‘llash;
- web’dagi kechikish reason UI’ni mobile’da ham ko‘rsatish;
- `reason_deadline` va `can_submit_reason`ni backenddan o‘qish;
- success/error message’larni localized mapping orqali ko‘rsatish.

## 9. Backend implementatsiya rejasi

### P0 — production/security blocker

1. `admit` target membership va pending request validation’ini qo‘shish.
2. Web clientdagi Data Channel moderation’ni o‘chirish; backend moderation action’larini qo‘shish.
3. Ticket consume’ni atomic va maqsadga bog‘langan qilish.
4. Backend meeting consumer, REST admit va LiveKit service uchun authorization testlarini yozish.
5. Web meeting WS URL scheme/path’ini tuzatish.

### P1 — cross-platform parity

1. `moderate_track`, `request_track_unmute`, `respond_track_unmute_request` action’lari.
2. `track_moderation_changed`, `moderation_error`, `track_unmute_requested`, `track_unmute_request_result` event’lari.
3. Canonical Data Channel schema va `version`.
4. Structured error va `request_id`.
5. UID exact filter/deep-link endpoint.
6. Attendance computed status/deadline field’lari.
7. Web global notification ticket parsing/host konfiguratsiyasini tuzatish.
8. Client tokenidan `room_admin`, `room_record`, `room_create`ni security review’dan keyin olib tashlash.

### P2 — production hardening

1. Duplicate admit/action idempotency.
2. Meeting-ended va expired request cleanup.
3. Rate limit: `ask_to_join`, moderation va unmute request.
4. Moderation audit log: actor, target, track, result, timestamp.
5. LiveKit webhook retry/idempotency va signature monitoring.
6. Redis/channel layer multi-instance testlari.
7. Nginx/LiveKit/UDP connectivity monitoring.

## 10. Mobile implementatsiya rejasi

1. `MeetingRealtimeMessage`ga moderation event entity’larini qo‘shish.
2. Repository va BLoC’ga host moderation/unmute event/action’larini qo‘shish.
3. `LiveKitMediaService`dan moderation message’larini olib tashlash; u faqat media va canonical Data Channel’ni qoldirsin.
4. Canonical chat/hand/reaction serializer/parser’ini web bilan tenglashtirish.
5. Participant metadata’dan `userId` va `deviceId`ni parse qilish.
6. `MeetingAttendance` model va organizer reason list’ni late flow bilan kengaytirish.
7. Terminal WS close code’larda reconnect’ni to‘xtatish.
8. UID deep-link resolve yoki route contract’ini web bilan bir xil qilish.
9. `get_token` action’iga persisted device ID/name yuborish.
10. Quyidagi testlarni qo‘shish:
   - meeting state / token response parse;
   - waiting organizer / approval / reject;
   - socket 4003/4004 terminal state;
   - moderation request/result parse;
   - canonical Data Channel messages;
   - late attendance reason va excuse list.

## 11. Web implementatsiya rejasi

1. `toWebSocketUrl()` helper yozish: `https` → `wss`, `http` → `ws`, `/api` suffix’ni saqlash.
2. Meeting WS uchun faqat bitta transport qoldirish; WS + REST admit double-submit’ni olib tashlash.
3. Global notification ticket body’sini `data.ticket` yoki umumiy API unwrap bilan o‘qish.
4. Notification backend host’ini hardcode qilmaslik; env’dan olish.
5. Client-side moderation payload’larini backend action’lariga almashtirish.
6. `track_moderation_changed` va unmute request event’larini UI’da ko‘rsatish.
7. localStorage chat’ni ephemeral cache sifatida aniq belgilash yoki backend history scope’ini alohida rejalash.
8. UID exact endpoint/filter ishlatish.
9. Attendance deadline/status’ni backend field’laridan olish.
10. Cross-platform smoke test: web organizer ↔ mobile participant va mobile organizer ↔ web participant.

## 12. Tavsiya etilgan test matrix

| Scenario | Backend | Web | Mobile |
|---|---:|---:|---:|
| Organizer join | required | required | required |
| Invited participant join | required | required | required |
| Non-member denied | required | required | required |
| Organizer waiting | required | required | required |
| Knock/admit/reject | required | required | required |
| Duplicate admit | required | required | required |
| Expired/invalid ticket | required | required | required |
| Meeting close to all clients | required | required | required |
| Multi-device same user | required | required | required |
| Attendance joined/left/duration | required | required | required |
| Late reason submit | required | required | required |
| Late reason review | required | required | required |
| Moderator mic mute | required | required | required |
| Moderator camera mute | required | required | required |
| Unmute request accept/reject/timeout | required | required | required |
| Chat cross-platform | required schema | required | required |
| Hand raise cross-platform | required schema | required | required |
| Reaction cross-platform | required schema | required | required |
| LiveKit reconnect | required webhook/state | required | required |
| Invalid moderation sender spoof | required deny | required | required |

## 13. Acceptance criteria

Audit natijasi production-ready deb hisoblanishi uchun:

- backend bo‘lmagan client-side moderation qolmasligi;
- oddiy participant moderation action yuborsa `not_allowed` olishi;
- target boshqa meeting a’zosi bo‘lmasa token/moderation berilmasligi;
- web va mobile aynan bir xil meeting WS URL/path ishlatishi;
- ticket bir marta va to‘g‘ri consumer uchun ishlashi;
- host tokenida ortiqcha LiveKit admin grantlari bo‘lmasligi;
- `meeting_state`, token, knock va terminal errors canonical schema’da bo‘lishi;
- web va mobile chat/hand/reaction payload’lari o‘zaro ko‘rinishi;
- web va mobile moderation event’larini o‘zaro ko‘rsatishi;
- attendance late/reason/24-hour status’i ikkala clientda bir xil bo‘lishi;
- organizer meeting yopganda LiveKit room, WS va attendance lifecycle to‘g‘ri yakunlanishi;
- API secret, Room Service credential yoki admin token browser/APK/IPA ichida bo‘lmasligi;
- backend authorization, concurrency, webhook va reconnect testlari yashil bo‘lishi.

## 14. Qisqa mas’uliyat chegarasi

| Funksiya | Backend kerakmi? | Izoh |
|---|---:|---|
| Meeting CRUD | Ha | REST source of truth |
| Join permission | Ha | membership va meeting state |
| Knock/admit | Ha | Channels + server authorization |
| LiveKit token | Ha | API secret faqat backendda |
| Audio/video | LiveKit + token | media track client/LiveKit’da |
| Screen share | LiveKit + infra | `can_publish`, RTC ports/proxy |
| Chat | Hozircha yo‘q | LiveKit Data Channel, ephemeral |
| Hand raise | Hozircha yo‘q | canonical Data Channel schema |
| Reaction | Hozircha yo‘q | canonical Data Channel schema |
| Moderator mute | Ha | Room Service orqali |
| Unmute request | Ha | consent, timeout, routing |
| Attendance | Ha | webhook + DB |
| Absence reason | Ha | attendance PATCH |
| Chat history | Faqat talab qilinsa | alohida persistence scope |

## Yakun

Web’dagi ko‘p UI funksiyasi hozircha client-side bo‘lishi mumkin, lekin authorization, meeting membership, token, attendance va moderation backend’da qolishi shart. Mobile va web bir xil ishlashi uchun backend avval yagona meeting/moderation/data protocol’ni mustahkamlashi, keyin ikkala client shu contract’ga moslashtirilishi kerak.

Eng birinchi bajariladigan ishlar: `admit` authorization bug’ini yopish, web WS URL’ini tuzatish, double admit’ni olib tashlash, ticket lifecycle’ni atomic qilish va moderation’ni LiveKit Data Channel’dan backend WebSocket + Room Service’ga ko‘chirish.
