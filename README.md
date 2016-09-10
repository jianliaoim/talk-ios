# 简聊 iOS

如果不想自己部署本地服务，可以直接下载 App: https://itunes.apple.com/cn/app/id922425179, 

## 安装之前

* 搭建本地服务:
具体介绍请参考 [talk-os](https://github.com/jianliaoim/talk-os)

* 打开工程，全局搜索 "http://192.168.0.35:7001", 将服务器地址替换成自己部署的服务器地址
* pod install
* 运行代码（真机调试可以使用 Apple 提供的证书,）


## 代码简介

* 代码主体由 OC 编写，登录部分由 Swift 编写
* 大部分 采用 MVC 的架构，登录部分 采用 MVVM 架构
* 网络层是对 [AFNetWorking](https://github.com/AFNetworking/AFNetworking) 的封装
* 数据层采用 [CoreData](https://developer.apple.com/library/watchos/documentation/Cocoa/Conceptual/CoreData/index.html) ＋ [MargicalRecord](https://github.com/magicalpanda/MagicalRecord) ＋ [Mantle](https://github.com/Mantle/Mantle)（因为性能的关系，部分地方是采用了 [FastEasyMapping](https://github.com/Yalantis/FastEasyMapping)）
* UI 层主要由 StoryBoard 构建


## 关于聊天

IM 是简聊的核心，iOS 端聊天的处理，希望可以为其他后来 IM 提供经验。具体逻辑如下：

* 消息的接收相关主要由 **SocketManager** 负责处理
* 消息的发送相关主要由 **MessageSendEngine** 负责处理

彼此互不干扰，可以很好的处理各种情况。

聊天界面的渲染主要是使用 UITableView，每条消息其实是 一个 section，这样可以处理各种复杂的附件消息组合。


