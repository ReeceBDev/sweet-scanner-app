# App Page Outline and Flow — Sweet Scanner

This document outlines the app's pages and flow, upon the requirements laid out under 'App Requirements.md'.

**Pages (MVP)**

- Camera (the app's first screen / root route)
- Document (per-document screen; hosts the text-list widget, the export view widget and the gallery shortcut)
- Library (mega list of every named entry)

**Widgets (not pages)**

- Session gallery (overlay widget, shown over the camera or the document screen)
- Text list (expand/collapse entry list widget inside the document screen)
- Export view (merged text block + action bar widget, inside the document screen)
- Name popup (modal widget, shared by naming and renaming)
- Confirmation popups (shared widgets: abandon work, delete photo, delete entry)

**PAGE BREAKDOWNS:

Camera**

- Live camera preview fills the screen.
- Top-left: Home button (icon). Pressing shows the abandon-work confirmation popup; only on "yes" is the session discarded and the Library opened.
- Bottom-left: gallery icon (shows count badge of photos taken this session).
- Bottom-centre: shutter button. Each press captures a still photo, stores it, and kicks off OCR for it asynchronously.
- Bottom-right: "Finished" button — hidden until at least one photo has been taken; pressing opens the Name popup.
- Camera permission denied state: wireframe message + retry button (no camera preview).

Session gallery (widget)**

- Full-screen overlay listing every photo taken in the current session, newest first.
- Pressing a photo expands it to a larger view.
- While expanded, two icons sit on the photo:
  - Trash icon — removes the photo from the session (after the delete confirmation popup).
  - Circular reset arrow icon — retake: replaces the photo with a fresh capture from the camera.
- Underneath the expanded photo: the OCR text box.
  - Collapsed by default; expands upward on press.
  - Contains the recognised text; while recognition is still running it shows an in-progress indicator, and it fills in when recognition completes.
  - Pressing a photo whose OCR has not completed triggers/awaits recognition asynchronously.
- A close control returns to the live camera.

Name popup (widget)**

- Modal popup with a text field; the on-screen keyboard appears with it.
- Confirm (tick/done) creates the named document from the session's photos + OCR text and navigates to the Text list screen.
- Cancel returns to the camera with the session intact.

Document screen**

- Hosts the text-list widget, the export view widget, the gallery shortcut and the Submit/Done actions.
- Top: the document title with a pen icon beside it. Pressing the pen opens the same popup/keyboard as the Name popup, prefilled; confirming renames the document.
- Beneath: one entry per photo, in capture order. Each entry:
  - Shows a compact preview (photo thumbnail + a text snippet).
  - Tapping expands/collapses the full OCR text.
  - Has a trash icon to its right; pressing it shows the delete confirmation popup (yes/no) before deleting.
- Bottom-left: gallery shortcut icon, then a camera icon to its right.
  - Camera icon — returns to the Camera screen for more photos (the session continues into this document's next "Finished" round).
  - Gallery shortcut — opens the Session gallery for the current session's photos.
- Bottom-right: Submit floating button.
  - Merges every entry's text, in entry order, into one block of text and reveals the Export view.
- Bottom-right: Done button.
  - Ends work on the document and returns to the Library.

Export view (widget, within the document screen)**

- Shows the merged block of text, scrollable.
- Bottom action bar with three icons:
  - Copy — puts the whole text on the clipboard.
  - Save — renders the text as an image file (white background, black text) and saves it to the device.
  - Share — renders the same image and opens the platform share sheet.
- Rendering the image happens on demand per action; the merged text is the single source.

Library**

- Mega list of every named entry (document), newest first.
- Each row: the document name (+ entry count). Pressing opens its Text list screen.
- Empty state: a wireframe message pointing at the camera (via the camera route).

**FLOWS:

Capture flow:**

- App opens straight into the Camera.
- Shutter press → photo stored → OCR starts (async) → camera stays live.
- Gallery icon → Session gallery → expand a photo → retake or trash it → read/expand its OCR text → close back to camera.
- "Finished" (after ≥1 photo) → Name popup → enter name → document screen.

Naming flow:**

- Finished → Name popup with keyboard → confirm → document created → document screen.
- Cancel → back to Camera, session intact.

Document editing flow:**

- Document screen → tap entries in the text list to expand/collapse.
- Trash on an entry → confirmation popup → entry removed.
- Pen beside title → Name popup (prefilled) → confirm → title updated.

More-photos flow:**

- Document screen → camera icon → Camera → take more photos → Finished → Name popup prefilled with the same document? NO — each Finished round names a NEW document. The camera icon simply starts a fresh capture round; the gallery shortcut on the document screen shows the document's entry photos.

Export flow:**

- Document screen → Submit (FAB) → merged text block + action bar.
- Copy → text on clipboard.
- Save → image file saved to the device; the app surfaces where it was saved.
- Share → platform share sheet with the image file.
- Done → Library.

Abandon flow:**

- Camera → Home button → confirmation popup → yes → session discarded → Library.
- (no → stays on Camera, session intact)

Re-entry flow:**

- Library → press a named entry → its document screen (edit, rename, delete entries, export again).
