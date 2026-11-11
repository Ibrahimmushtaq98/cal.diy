// React 19's types dropped the global `JSX` namespace (it now lives at `React.JSX`).
// Some libraries we depend on still reference the global one in their published types, most
// importantly react-select (`JSX.LibraryManagedAttributes` builds its public `Props`). Without
// this, those types silently fall back to `any`. This re-adds the global namespace as an alias
// of `React.JSX`, the same shape React 18 shipped. Remove it once those libraries stop using it.
import type { JSX as ReactJSX } from "react";

declare global {
  namespace JSX {
    type ElementType = ReactJSX.ElementType;
    interface Element extends ReactJSX.Element {}
    interface ElementClass extends ReactJSX.ElementClass {}
    interface ElementAttributesProperty extends ReactJSX.ElementAttributesProperty {}
    interface ElementChildrenAttribute extends ReactJSX.ElementChildrenAttribute {}
    type LibraryManagedAttributes<C, P> = ReactJSX.LibraryManagedAttributes<C, P>;
    interface IntrinsicAttributes extends ReactJSX.IntrinsicAttributes {}
    interface IntrinsicClassAttributes<T> extends ReactJSX.IntrinsicClassAttributes<T> {}
    interface IntrinsicElements extends ReactJSX.IntrinsicElements {}
  }
}
