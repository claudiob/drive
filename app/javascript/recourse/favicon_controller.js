import { Controller } from '/recourse/stimulus.js'

// A tab asks for 16 CSS pixels and twice that on a retina display. 64 is the next
// size up again, and a glyph scaled down reads better than one scaled up.
const SIZE = 64

// The tab wears the same icon as the page, drawn from the same font and in the same
// colour: no image to ship, no second place to change, and a model that renames its
// icon — or an app that recolours itself — renames this too.
export default class extends Controller {
  static values = { icon: String }

  async connect() {
    const { glyph, color } = this.#painting()
    if (!glyph) { return }

    // A character the font has not arrived with is a blank box, and `connect` runs
    // long before it arrives, so nothing is drawn until it has.
    await document.fonts.load(`${SIZE}px bootstrap-icons`)
    // Turbo may have taken the page away while the font was loading, and this link
    // went with it.
    if (!this.element.isConnected) { return }

    this.element.href = this.#drawn(glyph, color)
  }

  // One element answers both questions. The codepoint is in the stylesheet and
  // nowhere JavaScript can ask for it, so the way to read it is to have an element
  // wear the class and say what its `::before` would have said; and the primary
  // colour is `light-dark()` until something is painted in it, so the way to resolve
  // it is to paint something. Rendered rather than `display: none`, since a box that
  // is never generated has no pseudo-element to report on.
  #painting() {
    const probe = document.createElement('i')
    probe.className = `bi bi-${this.iconValue}`
    probe.style.cssText = 'position: absolute; visibility: hidden; color: var(--bs-primary-fg)'
    document.body.append(probe)
    const { content, color } = getComputedStyle(probe, '::before')
    probe.remove()

    return { glyph: this.#character(content), color }
  }

  #character(content) {
    if (!content || content === 'none') { return '' }

    return content.replace(/^["']|["']$/g, '')
  }

  #drawn(glyph, color) {
    const canvas = document.createElement('canvas')
    canvas.width = canvas.height = SIZE
    const context = canvas.getContext('2d')

    context.fillStyle = color
    context.font = `${SIZE * 0.9}px bootstrap-icons`
    context.textAlign = 'center'
    context.textBaseline = 'middle'
    context.fillText(glyph, SIZE / 2, SIZE / 2)

    return canvas.toDataURL('image/png')
  }
}
