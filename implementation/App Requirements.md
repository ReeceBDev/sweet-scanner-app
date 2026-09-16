# App Requirements — Sweet Scanner

This document captures the requirements for the Sweet Scanner app, as stated by the source brief (15.09.2026), broken down requirement-by-requirement. Page-level detail lives under 'App Page Outline and Flow.md'; the technical layering lives under 'Architecture Plan.md'; the build order lives under 'Implementation Plan.md'.

**Core concept**

- The user photographs pages of text.
- The phone's built-in OCR (Apple Vision on iOS) turns each photo into text.
- Photographed text is collected into named documents.
- A named document's text can be merged into one block, then copied, saved as an image file, or shared as an image file — the image of the text exists so the user can print it.

**Visual direction**

- Black and white wireframe. White background, black lines, black text.
- All sizes and colours come from theme token files; nothing is hardcoded in a widget.

**Requirement-by-requirement breakdown**

1. The first screen opens as a camera.

- The camera is the app's root route. No login, no splash menu.
- Camera permission is requested on first launch of the camera screen.
- The shutter captures a still photo.

2. Each photo is OCR-scanned once it has been taken.

- "the camera will use the iOS phone's built in OCS to scan pictures into text once a picture has been taken"
- OCR runs automatically for every captured photo, asynchronously (the camera stays usable while recognition runs).
- OCR uses the platform's own recogniser: Apple's Vision framework (VNRecognizeTextRequest) behind a platform channel — NOT a bundled third-party ML model.
- Recognition status is tracked per photo: running / done / failed.

3. After the first picture has been taken, the user may hit the "Finished" button.

- The Finished button is hidden (or disabled) until at least one photo exists in the current session.
- Pressing Finished ends the capture session and moves to naming.

4. Gallery icon on the left of the camera screen.

- Pressing it shows a list of all pictures taken in the current session.
- Pressing a picture expands it.

5. Each expanded picture may be:

- Trashed via the trash icon (picture removed from the session).
- Retaken with the circular reset arrow icon (picture replaced by a fresh capture).

6. Underneath each photo is an expand-upable text box containing the OCR text.

- The text box expands upward to reveal the recognised text.
- "The OCS should trigger for each photo upon pressing, asynchronously" — OCR for a given photo is ensured to run when the photo is pressed: if it has not completed, pressing shows its in-progress state and the text fills in when recognition lands. (Auto-trigger on capture remains the primary path; press-to-trigger is the guarantee that the text is fetched on demand.)

7. Pressing "Done" opens a popup asking for a name.

- The popup appears together with the on-screen keyboard.
- The name entered becomes the document's title.

8. After naming, a text-list screen opens.

- A list of the processed images' text entries; tapping an entry expands/collapses it.
- At the top: the entered title, with a pen icon beside it; pressing the pen allows renaming (same popup + keyboard).
- Each entry has a trash icon; deletion shows a confirmation yes/no popup first.

9. Submit floating button, bottom right of the text-list screen.

- Takes the whole text and merges it into one block of text.
- With the merged block shown, a bottom action bar offers: copy to clipboard, save as an image file, share as an image file.
- The image file is an image of the text (white background, black text, sized for printing).

10. Done button, bottom right of the text-list screen.

- Finishes work on the document and returns to the library (mega list).

11. Camera screen has a Home button in the top-left.

- Pressing it abandons the current work — but only after a confirmation popup (yes/no).
- Pressing Home takes the user to the library: a mega list of every named entry.
- Pressing an entry in the library opens its text-list screen.

12. Text-list screen has a camera icon, bottom-left.

- Pressing it returns to the camera screen for more photos.
- To the left of the camera icon is the gallery shortcut — the same session gallery as on the camera screen.

**Out of scope for MVP**

~~- Cloud sync / accounts~~ (local device storage only)
~~- Editing OCR text by hand~~ (not requested; entries display recognised text)
~~- Android/desktop OCR backends~~ (the recogniser is abstracted so one can be added later, but only the iOS Vision path is built)
