# FORA Templates

A template controls which sections appear on the generated page and in what order. Three templates are included. You can build your own.

---

## Included templates

| Template | Description | Best for |
|---|---|---|
| `three-act.json` | Default: hero → work → bring → cta → footer | Most applications |
| `work-first.json` | Leads with proof of work, hero second | Experienced designers with strong case studies |
| `single-statement.json` | Minimal: one statement + one case study + cta | Targeted, concise applications |

Set the template in your brief: `brief._meta.template_id = "work-first"` (or leave empty for `three-act`).

---

## Template schema

```json
{
  "template_id": "three-act",
  "section_order": ["nav", "act1_hero", "act2_work", "act3_bring", "direct_cta", "footer"],
  "section_config": {
    "act2_work": { "max_works": 3 },
    "act1_hero": { "include_signals_inline": true, "signals_position": "below_philosophy" },
    "act3_bring": { "show_credibility_anchors": false },
    "signal_cards": { "standalone": false }
  },
  "slot_map": {}
}
```

### Fields

**`section_order`** — array of section IDs in render order. Each ID must match an HTML file in `templates/sections/`. Available sections: `nav`, `act1_hero`, `act2_work`, `act3_bring`, `direct_cta`, `footer`, `signal_cards`.

**`section_config`** — per-section settings object. All fields are optional.

| Section | Config key | Type | Description |
|---|---|---|---|
| `act2_work` | `max_works` | number | Max work entries to render (default: 3) |
| `act1_hero` | `include_signals_inline` | boolean | Render signal cards inside Act 1 (default: true) |
| `act1_hero` | `signals_position` | string | `"below_philosophy"` or `"below_positioning"` |
| `act3_bring` | `show_credibility_anchors` | boolean | Never render on live pages — credibility anchors are context only (default: false) |
| `signal_cards` | `standalone` | boolean | If false, section is skipped when signals are already inline in act1 |

**`slot_map`** — maps brief field paths to slot names. Leave empty `{}` to use defaults. Only needed for custom templates with non-standard slot names.

---

## Building a custom template

1. Copy any existing template JSON from `templates/`
2. Rename it (e.g. `templates/my-template.json`)
3. Modify `section_order` to your preferred section sequence
4. All section HTML files in `templates/sections/` are available — any combination is valid
5. Set `template_id` in your brief to match the filename (without `.json`)
6. Run: `./run.sh --brief briefs/your-brief.json`

The template is selected per-application via the brief, not globally.

---

## Adding a new section

1. Create `templates/sections/your-section.html` with slot placeholders (`{{slot_name}}`)
2. Document the slots at the top of the file in a comment block
3. Add section-specific CSS in a `<style>` block at the bottom of the file
4. Add the section ID to any template's `section_order` where you want it
5. Add handling for your section's brief slice in `generate.js` `buildSectionBrief()`
