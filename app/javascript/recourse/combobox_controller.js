import { Controller } from '/recourse/stimulus.js'
import { Combobox } from '/recourse/bootstrap.bundle.min.js'

// The plugin keeps a menu's value in a hidden input it creates itself, which
// Turbo's DOM surgery knows nothing about: a morphing refresh deletes the input
// while the instance keeps writing to the detached node, and a snapshot restore
// resurrects an old input beside the one a new instance makes — either way the
// next click submits a filter that is stale, doubled or missing. Owning the
// lifecycle here keeps the input and the instance one thing.
export default class extends Controller {
  connect() {
    // A restored snapshot arrives with the last visit's input baked in. The
    // instance it belonged to is gone, so it is only a second submission.
    if (!Combobox.getInstance(this.element)) { this.#clearStaleInputs() }

    this.combobox = Combobox.getOrCreateInstance(this.element)
    this.morphed = () => this.#remake()
    document.addEventListener('turbo:morph', this.morphed)
  }

  disconnect() {
    document.removeEventListener('turbo:morph', this.morphed)
    this.combobox.dispose()
  }

  // Remade whole rather than repaired: the constructor reads the `.selected`
  // items the morph just made truthful, so disposing and starting over syncs the
  // input, the toggle's text and the listeners in one move.
  #remake() {
    if (!this.element.isConnected) { return }

    this.combobox.dispose()
    this.combobox = Combobox.getOrCreateInstance(this.element)
  }

  #clearStaleInputs() {
    const name = this.element.dataset.bsName

    for (const input of this.element.parentNode.querySelectorAll('input[type="hidden"]')) {
      if (input.name === name) { input.remove() }
    }
  }
}
