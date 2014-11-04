ヒレガス本の例題を Swift で書いてみる(2)

第５章「ターゲットとアクション」〜第６章「ヘルパオブジェクト」で取り上げられている「SpeakLine」アプリケーションを Swift で書いてみる。プログラムは `NSSpeechSynthesizer` を利用して入力したテキストを音声で読み上げるというもの。音声による読み上げ自体は `NSSpeechSynthesizer#startSpeakingString` にテキストを渡すだけなので特に難しいことは何もない。例題の目標は View と Controller を `IBOutlet` や `IBAction` で接続する方法、デリゲートやプロトコルの利用法についての学習。

![スクリーンショット 2014-11-04 22.15.06.png](https://qiita-image-store.s3.amazonaws.com/0/31482/22a0407e-1e32-5369-dcf7-19c993a01caf.png "スクリーンショット 2014-11-04 22.15.06.png")

以下、プログラムを書いていて引っかかった場所。

#### InitialFirstRespoder の設定  

書籍では `Window` の `InitialFirstRespoder` に `Text Field` を結びつけて、起動時に `Text Field` がフォーカスを取得するように設定することになっているが、今回は `Storybord` を利用しているため、その方法を利用することができず、また、`Storybord` も良く理解できていないので代替の方法も判らない。とりあえず、デフォルトの状態で `Text Field` がフォーカスを取得しているので、この件は今後の課題とする。

#### 文字列の長さを取得する方法

`NSString` には `Length` という文字列長を取得するメソッドが存在したが、Swift の `String` には同様のメソッドは存在しないようだ。

> [ios - Get the length of a String - Stack Overflow](http://stackoverflow.com/questions/24037711/get-the-length-of-a-string)    

上記、リンク先によると

```swift:sample
var length = countElements("test")
```

で取得できるとのこと。


```swift:ViewController.swift
import Cocoa

class ViewController: NSViewController, NSSpeechSynthesizerDelegate {

@IBOutlet weak var textField: NSTextField!
@IBOutlet weak var stopButton: NSButton!
@IBOutlet weak var speakButton: NSButton!
@IBOutlet weak var tableView: NSTableView!

let speechSynth = NSSpeechSynthesizer()
let voiceList = NSSpeechSynthesizer.availableVoices()

override func viewDidLoad() {
super.viewDidLoad()

// Do any additional setup after loading the view.
speechSynth.delegate = self

let defaultVoice = NSSpeechSynthesizer.defaultVoice()
for i in (0...voiceList!.count)
{
if (voiceList![i] as NSString) == defaultVoice
{
tableView.selectRowIndexes(NSIndexSet(index: i), byExtendingSelection: false)
tableView.scrollRowToVisible(i)
break
}
}
}

override var representedObject: AnyObject? {
didSet {
// Update the view, if already loaded.
}
}

@IBAction func sayIt(sender: AnyObject) {
var str = textField.stringValue
if countElements(str) > 0
{
speechSynth.startSpeakingString(str)
NSLog("Have started to say: \(str)")
stopButton.enabled = true
speakButton.enabled = false
tableView.enabled = false
}
else
{
NSLog("string from %@ is of zero-length", textField)
}
}

@IBAction func stopIt(sender: AnyObject) {
speechSynth.stopSpeaking()
NSLog("stopping")
}

func speechSynthesizer(sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool)
{
stopButton.enabled = false
speakButton.enabled = true
tableView.enabled = true
}

func numberOfRowsInTableView(aTableView: NSTableView) -> Int
{
return voiceList!.count
}

func tableView(aTableView: NSTableView,
objectValueForTableColumn aTableColumn: NSTableColumn?,
row rowIndex: Int) -> AnyObject?
{
let v = voiceList![rowIndex] as NSString
let dict = NSSpeechSynthesizer.attributesForVoice(v)
return dict![NSVoiceName]
}

func tableViewSelectionDidChange(aNotification: NSNotification)
{
let row = tableView.selectedRow
if row >= 0
{
let selectedVoice = voiceList![row] as String
speechSynth.setVoice(selectedVoice)
NSLog("New voice: \(selectedVoice)")
}
}
}

```