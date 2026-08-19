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
    // Read the form before flipping it. The verb it is still wearing is the one this
    // click means — `post` to keep the row, `delete` to drop it — while `render`
    // dresses it for the click after this one, which is the opposite.
    const body = new FormData(this.form)
    this.render(kept)
    this.pulse()
    this.send(body, kept)
  }

  // Removed and re-added rather than just added, with a read of `offsetWidth`
  // between the two to force the reflow that restarts it: without that, a second
  // click before the first ring has faded gets no ring at all.
  pulse() {
    this.element.classList.remove('recourse-kept')
    void this.element.offsetWidth
    this.element.classList.add('recourse-kept')
  }

  // What the eye reads, what a screen reader reads, and what the next click will do:
  // the path never changes, only the verb Rails wrote into the form.
  render(kept) {
    this.keptValue = kept
    this.icon.className = kept ? 'bi bi-bookmark-fill' : 'bi bi-bookmark'
    this.element.setAttribute('aria-pressed', kept)
    this.method.value = kept ? 'delete' : 'post'
  }

  // The token in the head, not the one in the form. Rails scopes a form's own token
  // to the method it was drawn with and this square flips that method; the form's is
  // inside a cached fragment besides, so it belongs to whichever session drew the
  // table. The head's is global to the session and fresh per request, and Rails takes
  // whichever of the two is valid.
  get token() {
    return document.querySelector('meta[name="csrf-token"]')?.content
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
  async send(body, kept) {
    try {
      const response = await fetch(this.form.action, {
        method: 'post',
        body,
        headers: { Accept: 'application/json', 'X-CSRF-Token': this.token },
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
