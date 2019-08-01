# react-native-color-thief
A react-native iOS API of [ColorThiefSwift](https://github.com/yamoridon/ColorThiefSwift)

`//TODO: Android`

## ColorThiefSwift
Grabs the dominant color or a representative color palette from an image.

![screen shot](https://github.com/yamoridon/ColorThiefSwift/blob/master/screenshot.png?raw=true "screen shot")


## Getting started
`$ npm install git://github.com/6DegreeLabs/react-native-color-thief.git --save`

`//TODO $ npm install react-native-color-thief --save`

## Mostly automatic installation

`$ react-native link react-native-color-thief`

## Manual installation

### iOS

**Requirements**
- Xcode 10.2
- Swift 5
- iOS 9

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-color-thief` and add `RNColorThief.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNColorThief.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)

### Android (TODO)

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNColorThiefPackage;` to the imports at the top of the file
  - Add `new RNColorThiefPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-color-thief'
  	project(':react-native-color-thief').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-color-thief/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-color-thief')
  	```

## Usage

```javascript
import RNColorThief from 'react-native-color-thief';

// get array of colors
RNColorThief.getPalette(imageUri,colorCount,quality,includeWhite).then((palette) => {
	console.log('palette', palette);	
}).catch((error) => {
	console.log('error', error);
});

// get dominant color
RNColorThief.getColor(imageUri,quality,includeWhite).then((color) => {
	console.log('color', color);	
}).catch((error) => {
	console.log('error', error);
});

```

## Example

```javascript
// customImage.js

import {Image,View,StyleSheet} from 'react-native'
import RNColorThief from 'react-native-color-thief';

const CustomImage = (props:Object) => {

	const {
		imageUri
		style,
		...imageProps
	} = props;

	const onLoad = ({nativeEvent}) => {
		// successful load
		const {source} = nativeEvent;
		
		if(	source && 
			source.url && 
			typeof source.url === 'string') {

			// get array of colors	
			RNColorThief.getPalette(source.url,5,1,true).then((palette) => {
				console.log('palette', palette);	
			}).catch((error) => {
				console.log('error', error);
			});

		}			
	}
			
	return imageUri && typeof imageUri === 'string' ? (
		<Image 
			source={{ uri: imageUri }}
			style={[styles.defaultImageStyle,style]}
			onLoad={onLoad}
			{...imageProps}
		/>
	) : (<View/>)

}

const styles = StyleSheet.create({
		defaultImageStyle: {
			width: '100%',
			height: '100%',
			resizeMode: 'contain'
		}
	});

module.exports = ItemDisplayImage;
```
  