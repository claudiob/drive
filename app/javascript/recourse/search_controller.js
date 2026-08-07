import { Controller } from '/recourse/stimulus.js'

// Survives the visit that a submit starts, since the module is not reloaded with
// the page: it is how the next controller knows the search box was being typed in.
let typing = false

export default class extends Controller {
  static targets = ['field']

  connect() {
    // Not on a cached preview: the real render connects a second time, and it is
    // the one whose field can still be typed into.
    if (typing && !document.documentElement.hasAttribute('data-turbo-preview')) {
      typing = false
      this.#restore()
    }

    // A combobox writes its hidden input from JavaScript, which fires no `change`
    // of its own. Bootstrap's own event bubbles, so one listener on the form hears
    // every menu in it, and each tick or untick narrows the table straight away.
    this.picked = () => this.#submit()
    this.element.addEventListener('change.bs.combobox', this.picked)
  }

  disconnect() {
    this.element.removeEventListener('change.bs.combobox', this.picked)
    clearTimeout(this.timer)
  }

  submit() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => { typing = true; this.#submit() }, 300)
  }

  #submit() {
    this.element.requestSubmit()
  }

  // The value comes back from the server, so only the caret has to be put back,
  // and at the end of it — typing carries on where it left off.
  #restore() {
    if (!this.hasFieldTarget) { return }

    const field = this.fieldTarget
    field.focus({ preventScroll: true })
    field.setSelectionRange(field.value.length, field.value.length)
  }
}
