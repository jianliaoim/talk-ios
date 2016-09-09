# talk-ios

## 安装之前

* 搭建本地服务:
具体介绍请参考 [talk-os](https://github.com/jianliaoim/talk-os)

* 打开工程，全局搜索 "http://192.168.0.35:7001",将服务器地址替换成自己部署的服务器地址
* pod install
* 运行代码（真机调试可以使用 Apple 提供的证书）


## 代码简介

* 代码主体由 OC 编写，登录部分由 Swift 编写
* 大部分 采用 MVC 的架构，登录部分 采用 MVVM 架构
* 网络层是对 [AFNetWorking](https://github.com/AFNetworking/AFNetworking) 的封装
* 数据层采用 [CoreData](https://developer.apple.com/library/watchos/documentation/Cocoa/Conceptual/CoreData/index.html) ＋ [MargicalRecord](https://github.com/magicalpanda/MagicalRecord) ＋ [Mantle](https://github.com/Mantle/Mantle)（因为性能的关系，部分地方是采用了 [FastEasyMapping](https://github.com/Yalantis/FastEasyMapping)）
* UI 层主要由 StoryBoard 构建


