# react-native-color-thief

A React Native node module that grabs the dominant color or a representative color palette from an image uri.

It's an adapted version of Kazuki Ohara 's [ColorThiefSwift](https://github.com/yamoridon/ColorThiefSwift) and Sven Woltmann's [color-thief-java](https://github.com/SvenWoltmann/color-thief-java) from Lokesh Dhakar's original javascript project [color-thief](https://github.com/lokesh/color-thief/)


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

### Android

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
Both `getColor` and `getPalette` return a `Promise`.

```javascript
import RNColorThief from 'react-native-color-thief';

// get array of color objects [{r,g,b}]
RNColorThief.getPalette(imageUri,colorCount,quality,includeWhite).then((palette) => {
	console.log('palette', palette);	
}).catch((error) => {
	console.log('error', error);
});

// get dominant color object {r,g,b}
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
  
## Troubleshooting

1. If you aren't currently using swift in your project, you may need to add a `dummy.swift` file with a bridging header in order to successfully build.