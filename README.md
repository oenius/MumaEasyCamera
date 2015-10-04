MumaEasyCamera
==================


![sample](./example.gif)

Requirements
----------
- iOS 7.0+
- Xcode 6.0+

How to use
----------

extension or init, both way supported

```objectivce-c
  MACameraController *controller = [[MACameraController alloc]init];
  controller.cancelBlock = ^(UIViewController *controller){
    [controller dismissViewControllerAnimated:YES completion:nil];
  };
  [self presentViewController:controller animated:YES completion:nil];

```

License
-------
	Copyright 2015 Oenius Jou
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	    http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
