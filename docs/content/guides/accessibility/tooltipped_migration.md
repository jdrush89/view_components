---
title: Tooltipped migration
---

## Rule details

The Primer CSS tooltip set using the `.tooltipped` class has been deprecated. There are major accessibility concerns with using this deprecated tooltip so please take action.

Depending on your usecase, there are two potential migration paths.

## 1. Don't use a tooltip.

Tooltips are not visible by default and can easily go unnoticed, so they should only be used as a last resort, and should never be used to convey critical information.

If `.tooltipped` is being set on a non-interactive element  (e.g. `<span>`, `<div>`, `<p>`), please consider an alternative. There is no way to make a tooltip fully accessible on a non-interactive element. See [Tooltip alternatives](https://primer.style/design/guides/accessibility/tooltip-alternatives/) or consult a designer.

## 2. Migrate to the more accessible PVC tooltip

If your tooltip is appropriately set on an interactive element, you can migrate to the latest [Tooltip component](https://primer.style/design/components/tooltip/rails/alpha) which has been implemented with accessibility considerations.

## Example scenarios

### Scenario 1

Flagged code:

```html
<span aria-label="Mona Lisa" class="tooltipped tooltipped-s">
  Mona Lisa
</span>
```

In this above example, we can get rid of the tooltip because it redundantly repeats the text content, like the following

```html
<span>Mona Lisa</span>
```

### Scenario 2

Flagged code:

```html
<button aria-label="This action is irreversible" class="tooltipped tooltipped-n">
  Submit
</button>
```

In this above example, the information that is conveyed using the tooltip is critical so we should not be using a tooltip to convey it. Update the design to always persist the text.

### Scenario 3

Flagged code:

```html
<a aria-label="A set of guidelines, principles, and patterns for designing and building UI at GitHub." class="tooltipped tooltipped-s" href="primer.style">
  Primer
</a>
```

In this above example, the information conveyed in this tooltip isn't necessarily critical but supplements the link. If we decide to permanently persist it,we can update the markup like so:

```html
<a aria-describedby href="https://primer.style/design/">
  Primer
</a>
<p id="primer-link-help">A set of guidelines, principles, and patterns for designing and building UI at GitHub.</p>
```

A tooltip is also a viable option in this scenario. We can render an accessible tooltip by using the slot of the Link component and setting the tooltip type to `:description`:

```.rb
render(Primer::Beta::Link.new(href: "https://primer.style/design/", id: "primer-link")) do |component|
  component.with_tooltip(type: :description, text: "A set of guidelines, principles, and patterns for designing and building UI at GitHub.")
  "Primer"
end
```
