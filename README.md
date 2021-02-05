# Hundred Rabbits theme editor

Create and edit [Hundred Rabbits themes](https://github.com/hundredrabbits/Themes) using this simple web app.

[**Click here to use the editor.**](https://dzuk-mutant.github.io/100r-theme-editor/)

**This app is currently unfinished, there's more to do, but it works enough at the moment that I wanted to make it available for other people.**

## Instructions

- Drag and drop themes into the window (or click the import button)
to view and edit them.
- Click on the different color names in the middle section to select them for editing.
- Use the color controls at the bottom section to adjust the selected color.
    - Click 'HSL' for HSL sliders and 'RGB' for RGB sliders.
    - You can use sliders or the text boxes next to them to edit color values.
    - You can enter hex values in the hex text box. (It will revert to the previous color if there was an error in the hex colour that you give.)
- All changes are immediate, and you can see the tests and accessibility score of your theme in real time.
- Click the download button to download your new theme.


### Testing

There are two components to testing a Hundred Rabbits theme:

#### Basic Tests

The way colours work in Hundred Rabbits themes is that the high, medium and low foreground and background colours should be contrasted against the background in order - `f_high` be more contrasting against the background than `f_med`, and so on.

The basic tests at the top will tell you if the contrast should be swapped (and arrows will appear on the colour buttons indicating as well). If they're all good, it will say 'passed!'.

#### Contrast

Each colour combination in the preview grid has a number and a grade attached. The number is a score showing how contrasted the colour combination is, and the grade tells you what WCAG guidelines it passes.

- 3 and under is 'X', which here means that it didn't pass any guidelines.
- 3 - 4.5 is 'A'. (recommended min. for people with regular vision)
- 4.5 - 7 is 'AA'. (recommended min. for people with 40/20 vision)
- 7 and above is 'AAA'. (recommended min. for people with 80/20 vision)

At the top of the theme, you'll see the overall 'theme contrast', this tells you the minimum contrast in your colour combinations.

There are no real wrong answers with contrast accessibility when it comes to making themes for yourself - some people absolutely need things that are contrasted enough, but some people much prefer lower contrast. These scores are just a tool to help you make informed design choices.


---

## Known bugs

The HSL sliders now work but get interpreted back into the main color in a slightly off way compared to other forms of input.

---

## Accessibility

- This has not been built with screenreaders in mind, I will look into it in the future if people ask for it.
- All measurements are in rems, so it will scale with text size.
- Internet is required for building but works offline once built.

---

## Building

Building requires the following:

- Elm 0.19.1 (can be installed via `npm install elm`)
- terser (can be installed via `npm install terser`)

Building the web app involves the `make all` command.

An internet connection is required for the initial build, but
the app will work offline once built.

---

## License

- This software is licensed CNPL v5.
- JetBrains Mono is licensed OFL 1.1.