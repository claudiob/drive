import { Controller } from '/recourse/stimulus.js'

export default class extends Controller {
  connect() {
    this.picked = false
    this.changed = () => { this.picked = true }
    this.closed = () => { if (this.picked) { this.picked = false; this.#submit() } }

    // A combobox writes its hidden input from JavaScript, which fires no `change`
    // of its own. And a multiple one stays open while it is picked from, so the
    // table waits for the menu to close rather than reloading under the cursor.
    this.element.addEventListener('change.bs.combobox', this.changed)
    this.element.addEventListener('hidden.bs.combobox', this.closed)
  }

  disconnect() {
    this.element.removeEventListener('change.bs.combobox', this.changed)
    this.element.removeEventListener('hidden.bs.combobox', this.closed)
    clearTimeout(this.timer)
  }

  submit() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.#submit(), 300)
  }

  #submit() {
    this.element.requestSubmit()
  }
}
