# MMVoiceEngine

MMVoiceEngine是基于iOS Speech框架的封装，主要提供了语音识别等相关功能。版本支持：>= iOS10。

## 项目结构

```
MMVoiceEngine
    |_ Project
    |   |_ MMVoiceEngine (framework工程文件)
    |   |_ MMVoiceEngine-Demo (Demo工程文件)
    |   |_ MMVoiceEngine.xcworkspace (项目工作区间)
    |_ README
    |_ SDK (framework生成路径)
  ```   
  
## 编译运行

已经编译好了，打开项目直接可以调试。编译过程如下：

MMVoiceEngine -> Project -> MMVoiceEngine.xcworkspace 打开项目。

Scheme先选择MMVoiceEngine，分别使用模拟器合真机进行编译。会编译出i386 x86_64 armv7 arm64架构类型的framework，并自动合并至MMVoiceEngine->SDK下。

Scheme再选择MMVoiceEngine-Demo，就可以进行调试了。

