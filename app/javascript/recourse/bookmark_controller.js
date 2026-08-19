import { Controller } from '/recourse/stimulus.js'
import { flash } from '/recourse/flash.js'

// The square that keeps a row, answered before the server does. The icon flips under
// the cursor and the request goes in the background, so the table is never redrawn
// and the row stays where the eye left it — until the next real page load, which is
// where the kept-first order belongs.
//
// The form is still a real one. Without this controller it submits, redirects and
// reloads, which is the same floor every other button here degrades to.
export default class extends Controller {
  static values = { kept: Boolean, error: String }

  connect() {
    this.form = this.element.closest('form')
    this.icon = this.element.querySelector('i')
    this.form.addEventListener('submit', this.submit)
  }

  disconnect() {
    this.form.removeEventListener('submit', this.submit)
  }

  // An arrow so `this` survives being handed to the listener, and so the same
  // function object is the one removed again.
  submit = (event) => {
    event.preventDefault()
    const kept = !this.keptValue
    this.render(kept)
    this.send(kept)
  }

  // What the eye reads, what a screen reader reads, and what the next click will do:
  // the path never changes, only the verb Rails wrote into the form.
  render(kept) {
    this.keptValue = kept
    this.icon.className = kept ? 'bi bi-bookmark-fill' : 'bi bi-bookmark'
    this.element.setAttribute('aria-pressed', kept)
    this.method.value = kept ? 'delete' : 'post'
  }

  // Rails' own override field, which `button_to` writes only for a delete — so a
  // square that started hollow has none until the first click makes one.
  get method() {
    let field = this.form.querySelector('input[name="_method"]')
    if (!field) {
      field = document.createElement('input')
      field.type = 'hidden'
      field.name = '_method'
      this.form.prepend(field)
    }
    return field
  }

  // The response is never rendered, but it is read: a 500, a dropped connection or
  // an expired session would otherwise leave a filled square that was never saved.
  // `Accept` is what tells the server this one wants no flash and no redirect.
  async send(kept) {
    try {
      const response = await fetch(this.form.action, {
        method: 'post',
        body: new FormData(this.form),
        headers: { Accept: 'application/json' },
      })
      if (!response.ok) this.revert(kept)
    } catch {
      this.revert(kept)
    }
  }

  // Put the square back, and say why — the one time this column speaks, since the
  // icon flipping is the only report a click that worked ever needs.
  revert(kept) {
    this.render(!kept)
    flash(this.errorValue)
  }
}
