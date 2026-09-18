# Mobile meeting uchun LiveKit integratsiyasi tahlili

Sana: 2026-09-16  
Loyiha: `dc_management_app` / Raqamli Boshqaruv

## Qisqa xulosa

LiveKit bu loyiha uchun mos. U audio, video, screen share va data channel uchun WebRTC SFU beradi. Figma dizaynini LiveKit example’iga bog‘lash shart emas: `livekit_client` faqat media/session qatlamini beradi, UI esa to‘liq bizning Flutter widgetlarimiz bo‘ladi.

Tavsiya:

1. `livekit_client` — asosiy Flutter SDK.
2. Mavjud meeting WebSocket — ticket, waiting room, knock/admit, token va meeting lifecycle uchun.
3. `components-flutter` — majburiy UI framework emas; kerak bo‘lsa uning `VideoTrackWidget`, layout yoki track indicator g‘oyalaridan foydalanish. `provider` asosidagi context daraxtini loyihaga to‘liq olib kirish tavsiya etilmaydi.
4. Ishtirokchini moderator sifatida mute qilish — backend LiveKit Room Service orqali.
5. Mute qilingan foydalanuvchiga mikrofon/kamera yoqish so‘rovi — alohida application-level WebSocket/Data packet flow. Mobil ilova foydalanuvchi roziligisiz mikrofon/kamerani qayta yoqmasligi kerak.

Umumiy baho: **texnik jihatdan amalga oshadi**, lekin moderator mute/request funksiyasi uchun backend contract’ida qo‘shimcha action/event’lar aniq belgilanib, test qilinishi kerak.

## 1. So‘rov va attached hujjat chegarasi

### Foydalanuvchi so‘rovi

- LiveKit `components-flutter`, `livekit` server repo va saytini o‘rganish.
- `meetings.md` backend qo‘llanmasini tekshirish.
- Figma’ga mos custom UI imkoniyatini baholash.
- Meeting tashkilotchisiga ishtirokchining mikrofon/kamerasini o‘chirish va qayta yoqish so‘rovini yuborish imkonini qo‘shish yo‘lini aniqlash.
- Natijani repo ichidagi `docs/` papkada to‘liq Markdown hujjat qilish.

### `meetings.md` dagi ko‘rsatmalar

Bu fayl backend/frontend integratsiya kontrakti sifatida talqin qilindi:

- global notification WebSocket va meeting WebSocket alohida;
- meeting socket faqat meeting detail ekranida ochiladi va chiqishda yopiladi;
- ticket REST orqali olinadi, keyin meeting-specific socket’ga ulaniladi;
- server `meeting_state`, `waiting_organizer`, `organizer_joined`, `knock_request`, `knock_response`, `token_response`, `meeting_ended` eventlarini beradi;
- LiveKit tokeni backend qaytargan `server_url` va `room_name` bilan ishlatiladi;
- davomat meeting tugagach yoki davomida attendance endpoint orqali olinadi;
- absence reason meeting emas, attendance resource’iga PATCH qilinadi.

Quyidagi nuqta `meetings.md`da yo‘q yoki yetarlicha aniqlanmagan:

- moderator mute/unmute uchun meeting WebSocket action/event kontrakti;
- “mikrofon/kamera yoqish so‘rovi” uchun event nomlari, approval/decline javoblari va timeout;
- mobil foydalanuvchi bir nechta qurilmadan kirganda qaysi identity/track boshqarilishi;
- `server_url` uchun `ws://`/`wss://` formatining barcha muhitlarda kafolati.

Shu sabab bu hujjatdagi moderator protokoli tavsiya etilgan contract hisoblanadi; backend jamoasi bilan tasdiqlanmaguncha endpoint/action nomlari final deb olinmasin.

## 2. LiveKit repo va paketlar tahlili

### `livekit/livekit`

Bu repo LiveKit serveri: Go’da yozilgan, audio/video/data’ni SFU orqali tarqatadi. Server JWT token, TURN/TCP/UDP, simulcast, selective subscription, moderation API, E2EE va webhook kabi imkoniyatlarni beradi.

Server mobil ilovaga embed qilinmaydi. Bizning backend yoki alohida LiveKit server deployment’i uning API’si bilan ishlaydi. JWT access token client’ga backend orqali berilishi to‘g‘ri yo‘l; API key/secret mobil app ichiga kiritilmaydi.

### `livekit/client-sdk-flutter` — tavsiya etilgan dependency

Flutter SDK `Room`, `LocalParticipant`, `RemoteParticipant`, `TrackPublication`, `VideoTrackRenderer` va room event’larini beradi. SDK o‘z UI’sini majburlamaydi, shuning uchun BLoC va Figma UI bilan moslashadi.

Asosiy imkoniyatlar:

- `Room.connect(serverUrl, token)`;
- `LocalParticipant.setMicrophoneEnabled(bool)`;
- `LocalParticipant.setCameraEnabled(bool)`;
- `LocalParticipant.setScreenShareEnabled(bool)`;
- `RoomEvent` orqali participant/track/connect/disconnect/mute state kuzatuvi;
- remote track’larni Flutter video widget’ida render qilish;
- data packet/RPC orqali application event’lar.

Loyiha hozir `web_socket_channel` ishlatadi. `livekit_client` qo‘shilganda LiveKit’ning ichki signaling WebSocket’i bilan meeting orchestration WebSocket’ini aralashtirmaslik kerak.

### `livekit/components-flutter`

Repo `LivekitRoom`, `ParticipantLoop`, `GridLayoutBuilder`, `CarouselLayoutBuilder`, `ParticipantTileWidget`, `ControlBar`, `ChatWidget`, `Prejoin` kabi tayyor widgetlar beradi. README’da state management `provider` asosida ekani ko‘rsatilgan. Paket `livekit_client`ga qo‘shimcha ravishda `provider`, `responsive_builder`, `flutter_background`, `chat_bubbles` va boshqa dependency’larni olib kiradi.

Figma’ga moslashish darajasi:

- participant loop va layout builder’lar composable — foydali;
- `participantBuilder` bilan tile’ni almashtirish mumkin;
- control bar’ni o‘zimiz chizish mumkin;
- tayyor `LivekitRoom`/context daraxtini BLoC arxitekturasiga to‘liq qo‘shish ortiqcha coupling beradi;
- komponent theme’i bizning `AppColors`, Manrope, ScreenUtil, asset va localization qoidalarimizni avtomatik bermaydi.

Xulosa: **Figma UI uchun imkoniyat bor**, ammo `components-flutter`ni butun ekran sifatida ko‘chirmaslik kerak. Eng sodda yo‘l — `livekit_client` bilan custom UI; zarur bo‘lsa komponent repo kodini reference sifatida o‘qish.

## 3. Mavjud loyiha bilan moslik

Loyihadagi muhim cheklovlar:

- Feature-First + Clean Architecture;
- barcha state management BLoC, Cubit taqiqlangan;
- meeting feature allaqachon data/domain/presentation qatlamlariga bo‘lingan;
- barcha yangi network data source `ResponseMapper`dan foydalanishi kerak;
- navigation `Routes` + `AppRouter` orqali;
- UI `AppColors`, generated `Assets`, ScreenUtil va localization’dan foydalanadi;
- `meeting_reason` va attendance contract allaqachon mavjud.

Shu sabab LiveKit feature’ini quyidagicha joylashtirish ma’qul:

```text
lib/features/meetings/
  data/
    data_sources/meeting_realtime_data_source.dart
    models/meeting_realtime_message_model.dart
    models/livekit_session_model.dart
    repository/meeting_realtime_repository_impl.dart
  domain/
    entities/meeting_room_session.dart
    entities/meeting_participant.dart
    entities/meeting_moderation_action.dart
    repository/meeting_realtime_repository.dart
    usecases/connect_meeting_usecase.dart
    usecases/request_to_join_usecase.dart
    usecases/moderate_participant_usecase.dart
  presentation/
    bloc/meeting_room_bloc.dart
    bloc/meeting_room_event.dart
    bloc/meeting_room_state.dart
    pages/meeting_room_page.dart
    widgets/meeting_video_grid.dart
    widgets/meeting_participant_tile.dart
    widgets/meeting_control_bar.dart
    widgets/meeting_waiting_room.dart
    widgets/meeting_participant_actions_sheet.dart
```

### BLoC va LiveKit lifecycle

`MeetingRoomBloc` `Room` va meeting WebSocket’ni boshqaradi. UI `Room`ga bevosita event listener ulab state tarqatmasin; SDK event’lari BLoC event’lariga map qilinsin.

Muhim lifecycle:

1. Meeting detail/room page ochiladi.
2. BLoC ticket oladi.
3. Meeting WebSocket ulanadi.
4. `meeting_state` parse qilinadi.
5. Kerak bo‘lsa waiting room yoki knock UI ko‘rsatiladi.
6. `token_response` kelgach `Room.connect()` chaqiriladi.
7. Page dispose yoki `meeting_ended` kelganda `Room.disconnect()` va meeting socket close qilinadi.

Global notification socket bu lifecycle’ga qo‘shilmaydi.

## 4. Backend contract asosidagi state machine

```text
idle
  -> ticketLoading
  -> socketConnecting
  -> waitingOrganizer       organizer_joined=false
  -> askingApproval          requires_approval && !is_approved
  -> joiningLiveKit
  -> connected
  -> ended / rejected / error
```

`meeting_state`dagi `is_host` faqat backend bergan authorization signal sifatida ishlatiladi. Mobil klient “admin” yoki “manager” roliga qarab o‘zi host vakolati yasamasin.

WebSocket xatolari:

- `4003`: authentication yoki meeting access yo‘q;
- `4004`: meeting topilmagan yoki tugagan;
- JSON `type=error`: xabarni toast/dialog orqali ko‘rsatish;
- socket close/reconnect holatida tokenni qayta olish qoidasi backend bilan kelishiladi.

## 5. Figma custom UI imkoniyati

To‘liq mumkin. LiveKit media layer UI’dan ajratilgan. Figma ekranini quyidagi qismlarga bo‘lish mumkin:

- yuqori pinned meeting header: title, connection state, participant count;
- responsive video grid/carousel;
- participant tile: video, avatar fallback, name, mute/camera badge, speaking state;
- bottom control bar: mic, camera, speaker, screen share, leave;
- participant actions sheet: organizer uchun mute mic, mute camera, request mic, request camera;
- waiting room / knock dialog;
- meeting ended dialog;
- chat yoki raise hand keyingi bosqichda.

Raw `Color`, `Icons.*`, hardcoded string va fixed logical pixels ishlatilmaydi. Tile va control’lar mavjud `TuiAvatar`, `AppColors`, generated assets, text extensions, ScreenUtil va l10n bilan quriladi.

Video rendering uchun SDK track widget’lari ishlatiladi; bu media renderingni qayta yozishdan saqlaydi. Tile decoration, labels, action sheet va layout esa Figma’ga tegishli bo‘ladi.

## 6. Moderator mute va qayta yoqish so‘rovi

### 6.1 Mute qilish

LiveKit server Room Service `MutePublishedTrack` orqali participant’ning audio yoki video track’ini mute qila oladi. Buning uchun:

- moderator server tomonidan `roomAdmin` vakolatiga ega bo‘lishi;
- target participant identity’si;
- ayni track’ning `track_sid` qiymati;
- `muted=true` bo‘lishi kerak.

Bu amalni mobil klient to‘g‘ridan-to‘g‘ri LiveKit server API’iga qilmasin: API key/secret yoki server admin token mobil qurilmaga berilmaydi. Mobil ilova backend meeting socket’iga action yuboradi, backend authorizationni tekshiradi va LiveKit Room Service’ni chaqiradi.

Tavsiya etilgan action:

```json
{
  "action": "moderate_track",
  "target_identity": "user-45",
  "track_source": "microphone",
  "operation": "mute"
}
```

Backend javobi/event’i:

```json
{
  "type": "track_moderation_changed",
  "target_identity": "user-45",
  "track_source": "microphone",
  "muted": true,
  "by_identity": "organizer-1"
}
```

`track_sid` backendda aniqlanishi eng ishonchli. Agar mobile action faqat `track_source` yuborsa, backend LiveKit’dan participant info olib amaldagi track SID’ni topishi kerak.

### 6.2 “Yoqish so‘rovi”

Bu ikki xil ma’noga ega; ikkalasini aralashtirmaslik kerak:

1. **Moderator backend orqali unmute qiladi.** LiveKit server `muted=false` bilan remote unmute’ni qo‘llashi mumkin, lekin self-hosted serverda `enable_remote_unmute` konfiguratsiyasi kerak bo‘lishi mumkin. Bu konferensiya privacy modeliga ta’sir qiladi.
2. **Moderator ishtirokchidan yoqishni so‘raydi.** Tavsiya etilgan model shu: moderator request yuboradi, ishtirokchi “Yoqish”ni bosgandan keyin o‘z `LocalParticipant`i `setMicrophoneEnabled(true)` yoki `setCameraEnabled(true)` chaqiradi.

Ikkinchi model uchun tavsiya etilgan contract:

```json
{
  "action": "request_track_unmute",
  "target_identity": "user-45",
  "track_source": "camera"
}
```

Targetga event:

```json
{
  "type": "track_unmute_requested",
  "request_id": "req-123",
  "from_identity": "organizer-1",
  "track_source": "camera",
  "expires_in": 30
}
```

Target javobi:

```json
{
  "action": "respond_track_unmute_request",
  "request_id": "req-123",
  "decision": "accept"
}
```

Acceptdan keyin target client local track’ni yoqadi. Reject/timeout bo‘lsa moderatorga status qaytadi. Client foreground’da bo‘lmasa push notification qo‘shish keyingi bosqich.

### 6.3 Muhim edge case’lar

- Participant track publish qilmagan bo‘lsa, mute action no-op/error bo‘lishi kerak.
- User track’ni unpublish qilib qayta publish qilsa, eski `track_sid` yaroqsiz bo‘ladi; backend yangi track state’ni olishi kerak.
- Bitta user ko‘p device bilan kirsa, identity collision siyosati backend bilan tekshirilsin. `meetings.md` multi-device’ni qo‘llashini aytadi, LiveKit esa bir room ichida identity unique bo‘lishini hujjatlashtiradi; demak device session identity dizayni alohida aniqlanishi kerak.
- Moderator o‘zini mute qila oladimi — explicit policy kerak.
- Organizer meeting’dan chiqsa, host vakolati va waiting room holati qanday o‘zgarishi backend bilan aniqlansin.
- Remote unmute default yoqilmasin; user consent modeli xavfsizroq.

## 7. Backend’dan so‘raladigan aniq contract

Implementatsiyadan oldin backend jamoasi quyidagilarni tasdiqlashi kerak:

1. Ticket endpoint’ining production path’i: `POST /api/notifications/tickets/`mi yoki base URL `/notifications/tickets/`mi.
2. Meeting socket authentication faqat query ticket orqali ekanligi.
3. Moderator role: faqat organizer yoki `is_host=true` qaytgan co-host’mi.
4. `moderate_track` action va `track_moderation_changed` event payload’i.
5. `request_track_unmute` action, target event, response va timeout.
6. Backend LiveKit Room Service’da `roomAdmin` tokenni o‘zi ishlatishi va clientga bermasligi.
7. Self-hosted LiveKit uchun `enable_remote_unmute` default/config qiymati.
8. `server_url` LiveKit client kutadigan URL ekanligi.
9. Multi-device identity formati.
10. Meeting socket reconnect va meeting tugagandan keyingi close semantics.

## 8. Minimal implementatsiya rejasi

### Bosqich 1 — vertical slice

- `livekit_client` dependency qo‘shish;
- Android/iOS camera/microphone permission va manifest/plist sozlamalari;
- ticket → meeting WebSocket → token → LiveKit connect;
- bitta custom participant tile va mic/camera local toggle;
- leave/meeting ended cleanup;
- analyzer/test.

### Bosqich 2 — Figma UI

- responsive video grid;
- Figma header/control bar;
- avatar/no-track/speaking/mute state;
- waiting room, knock/admit, error va ended screens;
- localization va light/dark theme.

### Bosqich 3 — moderation

- backend action/event contract;
- organizer-only participant action sheet;
- remote mic/camera mute;
- targetga mic/camera unmute request;
- accept/reject/timeout states;
- audit log talab qilinsa backend event’iga ulash.

### Bosqich 4 — production hardening

- network reconnect;
- permission denied va OS settings flow;
- audio route/Bluetooth;
- background/foreground lifecycle;
- poor network, camera unavailable, duplicate join;
- Android real device va iOS real device testlari;
- server authorization abuse testlari.

## 9. Risklar

| Risk | Ta’sir | Yechim |
|---|---|---|
| `components-flutter` provider arxitekturasi BLoC bilan to‘qnashadi | O‘rta | `livekit_client` + custom UI; componentlardan selektiv foydalanish |
| Mute/unmute server vakolati noto‘g‘ri beriladi | Yuqori | API secret faqat backendda; backend `is_host` authorization |
| Remote unmute privacy muammosi | Yuqori | default request/consent modeli; direct unmute faqat policy tasdiqlansa |
| iOS/Android permission va audio route | O‘rta | real qurilmada native setup va lifecycle test |
| Multi-device identity | Yuqori | user identity + device session contract’ini backend bilan aniqlash |
| Track SID almashishi | O‘rta | backend current participant info’dan track SID topishi |
| Figma va tayyor component theme farqi | Past | SDK track rendering, UI’ni loyihaning design system’i bilan chizish |

## 10. Qabul qilish mezonlari

- Organizer va taklif qilingan participant meeting’ga kira oladi; begona user kira olmaydi.
- Organizer kirmaganida participant waiting room’da qoladi.
- Approval talab qilinganda knock/admit ishlaydi.
- Token clientga faqat backend meeting flow orqali keladi.
- Camera/microphone toggle Figma UI bilan ishlaydi.
- Organizer target participant’ning published mic/camera track’ini mute qila oladi.
- Mute qilingan targetga unmute request boradi.
- Target accept qilsa, o‘z qurilmasida permission va local toggle orqali track yoqadi.
- Target reject qilsa yoki timeout bo‘lsa, moderatorga status ko‘rinadi.
- Meeting tugaganda LiveKit room va meeting socket tozalanadi.
- API secret, LiveKit admin token yoki raw server credential APK/IPA ichida bo‘lmaydi.
- `flutter analyze lib` 0 issue bilan yakunlanadi.

## 11. Manbalar

- [LiveKit server repository](https://github.com/livekit/livekit)
- [LiveKit Flutter Components repository](https://github.com/livekit/components-flutter)
- [LiveKit Flutter client SDK repository](https://github.com/livekit/client-sdk-flutter)
- [LiveKit Flutter SDK API reference](https://docs.livekit.io/reference/client-sdk-flutter/)
- [LiveKit participant management and moderation](https://docs.livekit.io/intro/basics/rooms-participants-tracks/participants/)
- [LiveKit data packets](https://docs.livekit.io/transport/data/packets/)
- [LiveKit server protocol: mute/unmute and Room Service](https://github.com/livekit/protocol/blob/main/protobufs/livekit_room.proto)
- [LiveKit Components rendering flowchart](https://github.com/livekit/components-flutter/blob/main/flowchart.md)
- Backend attached contract: `C:\Users\ummug\Downloads\Telegram Desktop\meetings.md`

## Yakuniy qaror

**Go.** LiveKit media engine sifatida mos, Figma custom UI to‘liq mumkin. Kodni `components-flutter` example’iga ko‘chirish shart emas; loyiha arxitekturasi uchun `livekit_client` + BLoC + custom widgetlar eng kam coupling beradi. Moderator mute va unmute request’ni boshlashdan oldin backend action/event contract’i yuqoridagi ko‘rinishda tasdiqlanishi kerak.
