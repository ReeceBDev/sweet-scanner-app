# Architecture Plan — Sweet Scanner

This document defines the technical layering for the app, mirroring the conventions proven in boxing_app (checked as the implementation reference). The governing rules are SOLID, with the single responsibility principle enforced hard: state lives in the state layer, persistence and platform work live in the data layer, pages are pure composition and navigation, and every visual element is a standalone widget. All sizes and colours belong to theme token files.

**Layer map (folder structure under lib/)**

- `main.dart` — entry point only: `runApp(const ScannerApp())`.
- `app/` — root widget + routing.
  - `scanner_app.dart` — builds every dependency once, exposes them via `MultiProvider`, wires the theme and the central route table.
  - `scanner_routes.dart` — every navigation target declared by name; pages navigate by name, never by building routes.
  - `scanner_route_arguments.dart` — typed route arguments.
- `data/` — platform + persistence. No Flutter widgets here.
  - `photos/photo_file_store.dart` — writes captured photos into the app documents directory, hands back stable paths, deletes on request.
  - `documents/scan_document_dto.dart` — serialisable document shape (id, name, createdAt, entries: photoPath + text).
  - `documents/scan_document_file_store.dart` — one JSON file per document under the documents directory.
  - `documents/scan_document_repository.dart` — create / rename / delete / list / read. The only document API the state layer sees (dependency inversion: controllers depend on this, not on files).
  - `ocr/text_recognition_gateway.dart` — abstract recogniser interface: `Future<String> recognize(String imagePath)`. (DIP — the state layer knows nothing about Vision.)
  - `ocr/vision_text_recognition_gateway.dart` — iOS implementation over a `MethodChannel`; native Swift side runs `VNRecognizeTextRequest` (accurate level, language correction on). Unsupported platforms throw a typed error the state layer turns into a failed status.
- `state/` — `ChangeNotifier` controllers + models + phase enums. All app state lives here; pages render it.
  - `capture/capture_session_controller.dart` — owns the camera session: camera lifecycle (via the camera package + permission_handler), the photo list, capture, delete, retake, and the per-photo OCR pipeline (kicks off recognition on capture; ensures it runs on demand). Exposes `hasPhotos` (gates the Finished button) and per-photo OCR status.
  - `capture/captured_photo.dart` — model: id, path, ocr status (idle/running/done/failed), text.
  - `capture/ocr_status.dart` — the status enum.
  - `document/document_editor_controller.dart` — one loaded document: title, ordered entries, rename, delete entry (with confirm decided by the page), and `mergedText` (single block, entry order).
  - `library/library_controller.dart` — lists every named document, newest first; exposes open-by-id.
- `pages/` — pure composition + navigation. A page builds controllers in `initState` (like boxing_app's `HomePage`), listens, and lays out widgets. No colours, sizes, or business logic hardcoded.
  - `camera_page.dart` (root route)
  - `document_page.dart` (route args: document id; hosts the text-list widget and the export view widget)
  - `library_page.dart`
- `widgets/` — standalone, single-purpose widgets. Reused pieces live at the top level with the `Scanner` prefix; feature pieces live in feature subfolders (boxing_app pattern).
  - `scanner_icon_button.dart`, `confirm_popup.dart` (yes/no popup widget), `text_prompt_popup.dart` (name/rename popup widget with keyboard), `expandable_text_box.dart` (the expand-upable OCR text box).
  - `capture/camera_preview_view.dart`, `capture/capture_button.dart`, `capture/gallery_entry_button.dart`.
  - `gallery/gallery_sheet.dart` (session gallery overlay), `gallery/gallery_photo_card.dart` (thumbnail + expand + trash + retake + text box beneath).
  - `document/text_list.dart` (the expand/collapse entry list — a widget, not a page), `document/document_entry_tile.dart` (single row + trash), `document/export_action_bar.dart` (copy / save / share), `document/merged_text_view.dart` (the rendered text block; wraps a `RepaintBoundary` for image capture).
- `theme/` — token files, `abstract final class` + static consts, doc comments. No widget declares a `Color` or raw size.
  - `colors.dart` — background (white), ink (black), disabled (grey) and nothing else unless a real need appears.
  - `sizes.dart` — spacing, icon sizes, button sizes, border widths.
  - `font_sizes.dart` — text scale tokens.
  - `theme.dart` — the wireframe `ThemeData` builder (white surface, black ink, outlined buttons, zero elevation).

**SOLID rules enforced**

- Single responsibility: one controller per concern (session, document, library); one widget per visual element; pages only compose.
- Open/closed: new recognisers (e.g. an ML Kit or desktop backend) plug in behind `TextRecognitionGateway` without touching the state layer.
- Liskov/Interface segregation: the gateway interface is tiny (one method); stores expose only the operations their controllers need.
- Dependency inversion: `ScannerApp` composes the concrete graph (store → repository → controllers) and injects it via providers; everything below depends on abstractions.
- State at the correct layer: page-local UI state (which card is expanded, which popup is open) may live in the page's `State`; anything that survives navigation, touches I/O, or drives logic lives in `state/`.

**Routing**

- `/` — Camera (initial route).
- `/library` — Library.
- `/document` — Document screen (hosts the text-list widget and the export view widget), args `DocumentRouteArgs(documentId)`.

**Platform + native OCR**

- iOS `Info.plist`: `NSCameraUsageDescription` (camera), `NSPhotoLibraryAddUsageDescription` (saving exported images).
- Native channel `sweet_scanner_app/ocr`: a small Swift handler in `ios/Runner/` wraps Vision (`VNRecognizeTextRequest`, `.accurate`, `usesLanguageCorrection = true`) and returns the recognised string. Errors surface as `PlatformException` and become `OcrStatus.failed` per photo.
- Export image: render `MergedTextView`'s `RepaintBoundary` to PNG; save via the photo-file-store pattern (documents dir) then hand to `share_plus` for share/save-to-Photos.

**Dependencies (pubspec)**

- `provider` — DI + ChangeNotifier plumbing (as boxing_app).
- `camera`, `permission_handler` — capture session.
- `path_provider` — documents/photos directories.
- `share_plus` — share sheet.
- No HTTP, no database — files + JSON only.

**Data flow (one direction)**

- Widget → controller method (intent) → repository/gateway (I/O) → controller state (`notifyListeners`) → widget rebuild. Widgets never talk to stores; stores never import Flutter widgets.
