wheel-bar-controller
====================

**Container view controller that simulates the behavior of a wheel to navigate through the view controllers. It's inspired by the Podcast app.**

### The Views of Wheel Bar Controller

It inherits from `UIViewController` having two views inside their basic view, a wheel bar view and the view containing your custom content. The wheel bar view provides the selection controls to navigation through the view controllers.

## Usage

Create your view controllers and assign them to the Wheel Bar Controller, like we do with Tab Bar Controllers. 
Wheel Bar will use the `title` attribute of each view controller as the label for the buttons. 

### Basic

```objective-c
UIViewController *v1 = [[UIViewController alloc] init];
UIViewController *v2 = [[UIViewController alloc] init];
UIViewController *v3 = [[UIViewController alloc] init];

[v1 setTitle:@"Books"];
[v2 setTitle:@"Entertainment"];
[v3 setTitle:@"Medical"];

[v1.view setBackgroundColor:[UIColor redColor]];
[v2.view setBackgroundColor:[UIColor blueColor]];
[v3.view setBackgroundColor:[UIColor greenColor]];

PXLWheelBarController *controller = [[PXLWheelBarController alloc] init];
[controller setViewControllers:@[v1,v2, v3]];
```

### Customization
Wheel Bar view utilizes `UIAppearance` to make easy to customize several attributes, including:

- Font
- Color
- Highlighted Color
- Selection Indicator Image
- Backgroung Image

Using it to customize some attributes would be like:

```objective-c
[[PXLWheelBar appearance] setBackgroundImage:@"background-image.png"];
[[PXLWheelBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"bullet.png"]];	
[[PXLWheelBar appearance] setTitlesColor:[UIColor whiteColor]];
[[PXLWheelBar appearance] setTitlesHighlightedColor:[UIColor colorWithRed:.52f green:.75f blue:0.f alpha:1.f]];
[[PXLWheelBar appearance] setTitlesShadowColor:[UIColor colorWithWhite:0.f alpha:.6f]];
```

### Snapshots

![Simple and Customized](http://pixel4.co/wheel-bar-controller/snapshot.png)

### Details

Deployed to iOS 5.0+ and it's ARC enabled.

## Contact

Fabio Teles

- http://github.com/pixel4
- http://twitter.com/pixel4
- hello@pixel4.co

## License

Wheel Bar Controller is available under the MIT license. See the LICENSE file for more info.