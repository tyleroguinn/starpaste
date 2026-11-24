# Starpaste keyboard for iPhone

A little iPhone app that adds a **Starpaste keyboard**: the same symbols and pastel night-sky look as the website, grouped by category, that you can switch to in any app (Messages, Notes, Instagram…).

- Tap a category chip at the top to jump to it (Planets, Zodiac, Aspects, Moons…).
- Tap a symbol to type it. The space bar flashes its name so you know what you typed.
- A **Recent** row at the top remembers your favorites.
- 🌐 switches back to your normal keyboard. Hold ⌫ to keep deleting.
- It doesn't need "Full Access" and never sees or sends anything you type.

The app you open from the home screen has setup steps, a box to try the keyboard, and every symbol as a tap-to-copy tile.

---

## Put it on your iPhone (about 20 minutes the first time)

### What you need

- A **Mac** with **Xcode** (free in the Mac App Store; it's a big download, so start it first).
- Your **iPhone** and its charging cable.
- Your **Apple ID**. A free one works. (A paid Apple Developer account, $99 a year, is only needed to share it with friends. See the end.)

### 1. Download the project

1. On GitHub, open the repo, tap the green **Code** button, then **Download ZIP**.
2. Double-click the ZIP in Downloads to unzip it.
3. Inside, open the **ios** folder and double-click **Starpaste.xcodeproj**. Xcode opens.

### 2. Sign in to Xcode with your Apple ID

1. In the menu bar: **Xcode → Settings… → Accounts**.
2. Click **+** at the bottom left, choose **Apple ID**, and sign in. Close the window.

### 3. Sign the app and the keyboard

The app and the keyboard each need your signature, so you do this twice.

1. In the left sidebar, click the blue **Starpaste** icon at the very top.
2. In the middle, under **TARGETS**, click **Starpaste**, then the **Signing & Capabilities** tab.
3. Make sure **Automatically manage signing** is ticked, and set **Team** to your name (it says "Personal Team").
4. Now click **StarpasteKeyboard** under TARGETS and set the same **Team**.

If Xcode shows a red error like *"Failed to register bundle identifier"* or *"not available"*, someone else already used that name. Fix it by changing the **Bundle Identifier** on both targets to something only you would use, for example:
- Starpaste: `com.yourname.starpaste`
- StarpasteKeyboard: `com.yourname.starpaste.keyboard`

(The keyboard's one must be the app's one plus `.keyboard` at the end.)

### 4. Get your iPhone ready

1. Plug the iPhone into the Mac. If the phone asks **Trust This Computer?**, tap **Trust** and enter your passcode.
2. On the iPhone, go to **Settings → Privacy & Security → Developer Mode**, turn it on, and let the phone restart. (If you don't see Developer Mode, do step 5 once first and it will appear.)

### 5. Install it

1. At the top of the Xcode window, click the device name next to **Starpaste** and pick **your iPhone**.
2. Click the **▶ Play** button (or press ⌘R). The first build takes a minute or two.
3. The first time, the iPhone will say the developer isn't trusted. On the iPhone go to **Settings → General → VPN & Device Management**, tap your Apple ID email, then **Trust**. Press ▶ in Xcode again.

The Starpaste app opens on your phone with the sun-and-moon icon. 🎉

### 6. Turn on the keyboard

1. On the iPhone: **Settings → General → Keyboard → Keyboards → Add New Keyboard…**
2. Under *Third-Party Keyboards*, tap **Starpaste**.
   (You can also use the **Open Settings** button in the Starpaste app, then **Keyboards**.)
3. You don't need to turn on *Allow Full Access*.

### 7. Use it

Open Messages (or any app), tap in the text box, then tap the 🌐 **globe** key until Starpaste appears. Or hold the globe and pick **Starpaste** from the list. Tap 🌐 again to go back.

---

## Good to know

- **With a free Apple ID, the app stops opening after 7 days.** Nothing is lost. Just plug the phone in, open the project in Xcode, and press ▶ again.
- **Zodiac signs may turn into purple emoji in Messages.** The keyboard types the exact same characters as the website. Some apps show signs like ♌ as emoji. That's the app's choice, not the keyboard's.
- **Keyboard doesn't show up after an update?** Delete the Starpaste app from the phone, press ▶ in Xcode again, and re-add the keyboard in Settings.
- **To add or remove symbols**, edit `ios/Shared/Symbols.swift`. Each line looks like `s("♌", "Leo")`. Then press ▶ again.

## Sharing with friends

To get it onto other people's phones you need the paid **Apple Developer Program** ($99 a year). Then you can use **TestFlight** (send friends an invite link, no cable needed) or put it on the App Store. With the paid account, installs also last a year instead of 7 days.
