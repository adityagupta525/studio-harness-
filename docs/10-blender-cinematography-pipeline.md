# 10 — Blender cinematography pipeline (future integration plan)

**Status: plan only. Nothing here is installed or connected.** The official Blender Lab MCP is listed in `policies/tool-manifest.yaml` as Stage 1, `not-installed`. Its install steps, tool names and port come from the official project's own README, read at install time `[TO VERIFY]`; this page records requirements, not commands.

## What is present today (audit, 2026-11-04)
- Blender **5.1.2** app at `/Applications/Blender.app` (no CLI on PATH; the binary answers `--version`).
- A Blender MCP tool set is visible in the Claude session. Follow-up audit (see [tool-install-policy.md](tool-install-policy.md)): the **server** is the official Blender Lab extension (v1.0.1, enabled in Claude Desktop), but the Blender-side add-on actually installed is the **community** BlenderMCP, not the official one. The bridge is therefore mismatched and is **not enabled**; nothing listens on port 9876.
- A native-app automation skill from a private pack listed in the workspace profile.md (if any) may drive Blender; Blender is also a standard 3D build route.

## Why Blender, why deterministic
Camera, lens and light become **data** instead of prompt guesses: position, focal length, depth of field, lighting setups and materials are reproducible, reviewable and diffable. This is the route for any shot where continuity of camera language matters more than novelty, and it spends no credits.

## 1. Requirements before any use
| Requirement | Why |
|---|---|
| `tool_install_or_update` approval, then a Stage 1 approval per scene | installing is a gated action |
| **localhost only**: bind to `127.0.0.1`, no port forwarding, no tunnel, no LAN or public exposure | the server executes commands for whoever can reach it |
| Treat Blender automation as **running with the user's privileges** | it is **not a security boundary**; a script can read and write what the user can |
| Work on a **copy** of the `.blend` in the run folder, never the only copy | reversible |
| No secrets, keys or client-confidential files inside the scene | scene files get shared |
| Read every script and add-on before enabling it | hooks and add-ons run code |
| Quit Blender to stop the server (kill switch) | simple, always works |

## 2. Deterministic scenes
- The **scene is built by a script** saved in the run folder; the `.blend` is a build product. Same script, same Blender version, same seed ⇒ same scene.
- Fixed units (metres, scale 1.0), fixed frame rate, fixed resolution, named collections, named objects (`CAM_S01`, `KEY_S01`).
- Record the Blender version and the script's SHA-256 in the metadata artifact.
- Randomness (scatter, noise) takes an explicit seed, recorded.

## 3. Camera and lens plan
Per shot, the plan fixes: camera position and rotation, **focal length (mm)**, sensor size and fit, **lens choice rationale** (why this focal length serves the story purpose), aperture (f-stop) and **focus distance** for depth of field, clip range, shift, and the movement path with its keyframes. Lens rationale is written in plain words next to the numbers.

## 4. Lighting and materials
Key, fill, rim, practical lights named and positioned; colour temperature and intensity recorded; world/environment recorded. Materials are procedural or from assets with a rights row. Third-party textures and models need a cleared `rights.csv` row like any asset.

## 5. Preview before final
1. **Preview renders** at low resolution and low samples for each shot's key frame.
2. A **contact sheet** (all shots, one image) for continuity review by `qa-rights-reviewer`.
3. Only after review and the owner's approval is the **final render** started (local compute; if a paid render farm is ever used, it is `paid_generation`).

## 6. Verification before first use
Done once, in a run folder, and recorded in `decision-log.md`:
1. Confirm the server's project, version and README against the official source `[TO VERIFY]`.
2. Confirm it listens on `127.0.0.1` only (for example `lsof -nP -iTCP -sTCP:LISTEN` shows the loopback address, not `*`).
3. Open a scratch `.blend`; run one read-only call (list objects); record the output.
4. Build a trivial scene by script; render a 64-pixel preview; confirm the metadata artifact is written.
5. Quit Blender; confirm the port closes.

## 7. Metadata artifact (camera and lens)
Written next to each shot's preview as `runs/<run-id>/blender/S01.meta.json`. Illustrative shape; values are placeholders:

```json
{
  "schema_version": 1,
  "shot_id": "S01",
  "blender_version": "[recorded from the app]",
  "script_sha256": "[recorded]",
  "units": "metric",
  "frame_rate": 24,
  "resolution": [1920, 1080],
  "render_engine": "[recorded]",
  "seed": 0,
  "camera": {
    "name": "CAM_S01",
    "location_m": [0.0, 0.0, 0.0],
    "rotation_euler_rad": [0.0, 0.0, 0.0],
    "sensor_width_mm": 36.0,
    "focal_length_mm": 35.0,
    "lens_rationale": "[plain words: why this focal length]",
    "f_stop": 2.8,
    "focus_distance_m": 3.0,
    "dof_enabled": true,
    "clip_start_m": 0.1,
    "clip_end_m": 100.0
  },
  "lights": [{"name": "KEY_S01", "type": "area", "power_w": 0, "colour_temp_k": 0}],
  "preview": {"path": "S01.preview.png", "samples": 0},
  "approval_id": "AP-000"
}
```

## 8. Handoff to the rest of the pipeline
The metadata feeds the shot spec's `camera`, `lens` and `movement` fields, so a Blender previz shot and a generated shot can share the same camera language. Previz frames are `own` assets (rights row) and may be used as model input only once their rights row is cleared.

## Not in v1
Installing the MCP, launching Blender automation, any render, any account or network exposure.
