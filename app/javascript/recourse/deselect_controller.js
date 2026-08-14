import { Controller } from '/recourse/stimulus.js'

export default class extends Controller {
  // Clicking each chosen item is what the plugin is already listening for, so the
  // hidden input, the toggle's text and the events stay its business rather than
  // ours — it has no method for this, and reaching into its state would be guessing.
  all() {
    const menu = this.element.closest('.menu')

    // `All` is also how the options with none of the rows behind them are asked for:
    // they are in the menu already, and this is what puts them on it.
    for (const empty of menu.querySelectorAll('.menu-item.d-none')) {
      empty.classList.remove('d-none')
    }

    for (const item of menu.querySelectorAll('.menu-item.selected')) {
      item.click()
    }
  }
}
