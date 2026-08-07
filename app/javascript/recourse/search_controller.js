import { Controller } from '/recourse/stimulus.js'

export default class extends Controller {
  connect() {
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
    this.timer = setTimeout(() => this.#submit(), 300)
  }

  #submit() {
    this.element.requestSubmit()
  }
}
