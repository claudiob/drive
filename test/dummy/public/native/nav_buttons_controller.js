import { BridgeComponent } from '/vendor/hotwire-native-bridge.js'

// Hands the page's own buttons to the native navigation bar, and clicks the element
// back when one is tapped — so the behavior stays in the HTML and only the chrome is
// native. In a browser, where no native side answers, the buttons stay as they are.
export default class extends BridgeComponent {
  static component = 'nav-buttons'
  static targets = ['button']

  // Plain Stimulus `connect`, and `super` first: the base class installs the listener
  // that replays this on `native:restore`, when a cached page comes back.
  connect() {
    super.connect()

    this.send('connect', this.#buttons(), (message) => {
      document.getElementById(message.data.id)?.click()
    })
  }

  #buttons() {
    const at = (placement) =>
      this.buttonTargets
        .filter((button) => (button.dataset.navPlacement || 'trailing') === placement)
        .map((button) => ({
          id: button.id,
          title: button.dataset.navTitle || button.textContent.trim(),
          symbol: button.dataset.navSymbol || null,
          prominent: button.dataset.navProminent === 'true'
        }))

    return { leading: at('leading'), trailing: at('trailing') }
  }
}
