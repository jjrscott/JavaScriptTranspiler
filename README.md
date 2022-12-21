
This **experimental** JavaScript [transpiler](https://en.wikipedia.org/wiki/Source-to-source_compiler) generates a single Swift file from one or more JavaScript files and a types description. Here's a simple example below from the most excellent [Rosetta Code](https://rosettacode.org/wiki/Binary_search):

```javascript
function binary_search_recursive(a, value, lo, hi) {
    if (hi < lo) { return null; }
    
    var mid = Math.floor((lo + hi) / 2);
    
    if (a[mid] > value) {
        return binary_search_recursive(a, value, lo, mid - 1);
    }
    if (a[mid] < value) {
        return binary_search_recursive(a, value, mid + 1, hi);
    }
    return mid;
}
```

```json
{
  "BinarySearch.js" : {
    "binary_search_recursive" : {
      "@generic" : "T: Comparable",
      "@return" : "Int?",
      "a" : "[T]",
      "hi" : "Int",
      "lo" : "Int",
      "mid" : null,
      "value" : "T"
    }
  }
}
```

```swift
func binary_search_recursive<T: Comparable>(_ a: [T], _ value: T, _ lo: Int, _ hi: Int) -> Int? {
    if hi < lo {
        return nil
    }
    var mid /* BinarySearch.js, binary_search_recursive, mid */ = Math.floor(lo + hi / 2)
    if a[mid] > value {
        return binary_search_recursive(a, value, lo, mid - 1)
    }
    if a[mid] < value {
        return binary_search_recursive(a, value, mid + 1, hi)
    }
    return mid
}
```

Note that in order for this code to compile you'll need an additional function:

```swift
enum Math {
    static func floor(_ value: Int) -> Int { value }
}
```

## What's the point?

I wished to use some JavaScript in an iOS app without using either WebKit or JavaScriptCore (whether that was a good idea or not is left to the reader).

There are some uses though. When the above code is opened in Xcode the following warning is shown:

> Variable 'mid' was never mutated; consider changing to 'let' constant
> 
> Replace 'var' with 'let'



## Details

JST uses [Esprima](https://esprima.org) to parse the JavaScript, then attempts to map the resulting abstract syntax tree to the Swift equivalent using the type annotation file provided. JST will also update the type file to reflect any changes in the source JavaScript so you don't need to manage the structure yourself.

## Usage

```shell
USAGE: java-script-transpiler --output <output> [--types <types>] <input> ...

ARGUMENTS:
  <input>

OPTIONS:
  --output <output>
  --types <types>
  -h, --help              Show help information.
```

## Limitations

The following [ESTree](https://github.com/estree) node types are currently unsupported:

- AssignmentPattern
- ClassExpression
- DebuggerStatement
- ExportAllDeclaration
- ExportDefaultDeclaration
- ExportNamedDeclaration
- ExportSpecifier
- Import
- ImportSpecifier
- LabeledStatement
- Literal (regex)
- MetaProperty
- ObjectPattern
- RestElement
- SequenceExpression
- SpreadElement
- TaggedTemplateExpression
- WithStatement
- YieldExpression
