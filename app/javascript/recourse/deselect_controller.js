import { Controller } from '/recourse/stimulus.js'

export default class extends Controller {
  // Clicking each chosen item is what the plugin is already listening for, so the
  // hidden input, the toggle's text and the events stay its business rather than
  // ours — it has no method for this, and reaching into its state would be guessing.
  all() {
    for (const item of this.element.closest('.menu').querySelectorAll('.menu-item.selected')) {
      item.click()
    }
  }
}
