# Page Functional Requirements — Sweet Scanner

This document details each page's functional requirements / features, to prepare for sketches.
The pages are based off of 'App Page Outline and Flow.md' and the requirements under 'App Requirements.md'.

**Required MVP pages**

* Camera (the app's first screen)
* Document (per-document screen; hosts the text-list widget, the export view widget and the gallery shortcut)
* Library (mega list of every named entry)

**Widgets (not pages)**

* Session gallery (overlay widget over the camera or the document screen)
* Text list (expand/collapse entry list widget inside the document screen)
* Export view (merged text block + action bar widget inside the document screen)
* Name popup (modal widget, shared by naming and renaming)
* Confirmation popups (abandon work, delete photo, delete entry)

**PAGE BREAKDOWNS:
Camera**

* Live camera preview filling the screen.
* Home button, top-left (icon).
  * Pressing shows the abandon-work confirmation popup (yes/no).
  * Yes: session discarded, navigate to Library. No: stay, session intact.
* Gallery icon, bottom-left, with a count badge of photos taken this session.
  * Pressing opens the Session gallery overlay.
* Shutter button, bottom-centre.
  * Each press captures a still photo into the session and starts its OCR asynchronously.
  * First capture reveals the Finished button.
* Finished button, bottom-right.
  * Hidden until at least one photo exists in the session.
  * Pressing opens the Name popup.
* Permission-denied state: wireframe message with a retry button in place of the preview.

Session gallery (widget)**

* List of all photos taken this session, newest first; pressing a photo expands it.
* Expanded photo carries two icons:
  * Trash icon — delete confirmation popup (yes/no), then the photo is removed from the session.
  * Circular reset arrow icon — retake: a fresh capture replaces the photo; its OCR state resets and re-runs.
* Underneath the expanded photo: the OCR text box.
  * Collapsed by default; expands upward on press.
  * Shows the recognised text; while recognition runs it shows an in-progress indicator, on failure a retry control.
  * Pressing a photo whose recognition has not completed triggers/awaits it asynchronously.
* Close control returns to the live camera.

Name popup (widget)**

* Modal popup + on-screen keyboard appearing together.
* Text field for the document name; prefilled when used for renaming.
* Confirm: creates (or renames) the document; on create, navigates to the Text list screen.
* Cancel: returns with the session/document unchanged.

Document screen**

* Hosts the text-list widget, the export view widget, the gallery shortcut and the Submit/Done actions.
* Title row at the top: document name + pen icon.
  * Pen opens the Name popup prefilled; confirming updates the title.
* One entry per photo, in capture order. Each entry:
  * Collapsed: thumbnail + text snippet.
  * Tap: expands/collapses the full OCR text.
  * Trash icon at its right: delete confirmation popup (yes/no) before removal.
* Bottom-left: gallery shortcut icon, then the camera icon to its right.
  * Gallery shortcut: opens the Session gallery for the current session's photos.
  * Camera icon: returns to the Camera to take more photos (a new Finished round names a new document).
* Submit floating button, bottom-right.
  * Merges all entry text, in order, into one block and reveals the export view.
* Done button, bottom-right.
  * Returns to the Library.

Export view (widget, within the document screen)**

* The merged block of text, scrollable, white background black text.
* Bottom action bar, three icons:
  * Copy — whole text to the clipboard.
  * Save — renders the text as an image file and saves it to the device.
  * Share — renders the same image and opens the platform share sheet.

Library**

* Mega list of every named entry, newest first.
* Each row: document name + entry count; pressing opens its Text list screen.
* Empty state: wireframe message directing the user to the camera.

Confirmation popups (shared)**

* Yes/no wireframe popup.
* Used by: abandon work (camera Home), delete photo (gallery), delete entry (text list).
