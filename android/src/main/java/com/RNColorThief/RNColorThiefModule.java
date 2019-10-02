
package com.RNColorThief;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;


public class RNColorThiefModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNColorThiefModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNColorThief";
  }

  private WritableMap getDefaultColor() {
    WritableMap resultData = new WritableNativeMap();
    resultData.putInt("r", 0);
    resultData.putInt("g", 0);
    resultData.putInt("b", 0);
    return resultData;
  }

  @ReactMethod
  public void getPalette(String imageUrl, int quality, int count, boolean ignoreWhite, int width, int height, Promise promise) {
    try {
      int[][] rgb = RNColorThief.getPalette(imageUrl, quality, count, ignoreWhite, width, height);


      WritableArray resultArray = new WritableNativeArray();

      for (int i = 0; i < rgb.length; i++) {
        WritableMap resultData = new WritableNativeMap();
        resultData.putInt("r", rgb[i][0]);
        resultData.putInt("g", rgb[i][1]);
        resultData.putInt("b", rgb[i][2]);
        resultArray.pushMap(resultData);
      }

      promise.resolve(resultArray);
    } catch (Exception ex) {
      WritableArray resultArray = new WritableNativeArray();
      resultArray.pushMap(getDefaultColor());
      promise.resolve(resultArray);
    }
  }

  @ReactMethod
  public void getColor(String imageUrl, int quality, boolean ignoreWhite, int width, int height, Promise promise) {
    try {
      int[] rgb = RNColorThief.getColor(imageUrl, quality, ignoreWhite, width, height);

      WritableMap resultData = new WritableNativeMap();
      resultData.putInt("r", rgb[0]);
      resultData.putInt("g", rgb[1]);
      resultData.putInt("b", rgb[2]);

      promise.resolve(resultData);
    } catch (Exception e) {
      promise.resolve(getDefaultColor());
    }
  }
}
