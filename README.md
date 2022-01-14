# Model-View-Intent Todo

This project is a kind of attempt to test MVI architecture and Unidirectional flow in practice.

A simple application for creating Todo tasks was taken as a basis. In order not to get bogged down in the implementation details, the API layer simulates the execution of network requests. Hope that in the future I will have time to implement a true API layer.

User actions and view states are delivered to each layer via observable streams. These streams are unidirectional. Namely, the user produces intents that transform into particular mutations of the state. Each mutation updates the state instance that passed to the view for rendering.

![Unidirectional Flow](https://github.com/alounce/MVITodo/blob/master/Docs/Pictures/UnidirectionalFlow.jpg?raw=true)

## Unresolved questions

1. The view (ViewController) still needs to store parts of the state to make a datasource for controls like UITableView, UICollectionView (the ones that show only a relatively small part of the data that is currently visible on the screen). However, as I understand it, in the ideal case, the view should not store the state - it should simply render it.
   
2. If the view is complex enough and requires huge state, then every small state change causes the whole view to be re-rendered, which can be inefficient. So it would be nice to somehow implement "intelligent" rendering and re-render only state changes. This is a separate and rather difficult task.

## Some Diagrams

![Module Components](https://github.com/alounce/MVITodo/blob/master/Docs/Pictures/Module.Components.jpg?raw=true)


