
# Mapping Shortcuts

[![Build Status](https://app.travis-ci.com/moff4/ShortCuts.svg?branch=master)](https://app.travis-ci.com/moff4/ShortCuts)
[![CodeFactor](https://www.codefactor.io/repository/github/moff4/shortcuts/badge)](https://www.codefactor.io/repository/github/moff4/shortcuts)
[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/komissarov)

python package with useful mapping shortcuts

## Installation

``` bash
pip install mapping-shortcuts
```

## Contains  

 - Function decorator for mapping factory
 - Class decorator for mapping factory
 - Metaclass for mapping factory
 - Function for import all subpackages in package  
 - CLI param parser and processor

### Decorator factory for mapping

#### function decorator
```python

from mapping_shortcuts.decors import create_collector

decorator, collection = create_collector(
    raise_on_duplicate=True,  # default: True
)

@decorator('key1')
def func1():
    ...

@decorator('key2')
def func2():
    ...

print(collection) 
'''
output: {
    'key1': <function func1 at 0x104adc430>,
    'key2': <function func2 at 0x104adc4c0>,
}
'''

```

#### class decorator
```python

from mapping_shortcuts.decors import create_class_collector

decorator, collection = create_class_collector(
    raise_on_duplicate=True,  # default: True
    key_getter=lambda x: x.key  # default: lambda x: x.__name__
)

@decorator
class SomeClass1:
    key = 123

@decorator
class SomeClass2:
    key = 456 

print(collection) 
'''
output: {
    123: <class '__main__.SomeClass1'>,
    456: <class '__main__.SomeClass2'>,
}
'''

```

### Metaclass factory for mapping

```python
import abc
from mapping_shortcuts.meta import create_collection_meta

MetaClass, collections = create_collection_meta(
    base=abc.ABCMeta,  # default: type
    getter=lambda x: x.__name__,  # default: lambda x: str(x)
    raise_on_duplicate = True,  # default: True
)


class A(metaclass=MetaClass):
    ...

class B(metaclass=MetaClass):
    ...

print(collections)
'''
oputput: {
    'A': <class '__main__.A'>,
    'B': <class '__main__.B'>,
}
'''
```

### Function for import all subpackages in package

For exmaple with have five files:
- python code `app/tools.py`
- empty file `app/providers/a/__init__.py`
- empty file `app/providers/b/__init__.py`
- python code in `app/providers/a/module.py`
- python code in`app/providers/b/module.py`

`app/tools.py` be like:

```python
from mapping_shortcuts.decors import create_collector

decorator, collection = create_collector()
```

`app/providers/a/module.py` is: 
```python
from app.tools import decorator

@decorator('A-func')
def function_a():
    ...
```

`app/providers/b/module.py` is: 
```python
from app.tools import decorator

@decorator('B-func')
def function_b():
    ...
```

execute `load_package()`:
```python

from mapping_shortcuts.dirtools import load_package
from app.tools import collection

load_package('app.providers')
print(collection)
'''
output: {
    'A-func': <function function_a at 0x104cfa0e0>,
    'B-func': <function function_b at 0x104cfa290>,
}
'''
```

### CLI param parser and processor


```python

from pydantic import BaseModel, Field

from mapping_shortcuts.cli import cli_handler, process_sysargv


@cli_handler('command1', desc='run handler for command1')
def handler_1(args: dict[str, str | bool]) -> None:
    print('command 1 handled!')


class ArgModel(BaseModel):
    x: int = Field(alias='--x', description='arg x')
    y: int = Field(alias='--y', description='arg y')


@cli_handler('command2', desc='sum X and Y', model=ArgModel)
def handler_1(args) -> None:
    print(f'{args.x=}')
    print(f'{args.y=}')
    print(f'result: {args.x + args.y}')


@cli_handler('command3', desc='sum X and Y')
def handler_1(args: ArgModel) -> None:
    print(f'{args.x=}')
    print(f'{args.y=}')
    print(f'result: {args.x + args.y}')


if __name__ == '__main__':
    process_sysargv(
        help_msg_header='That\'s my program!',
        help_msg_run_cmd='python -m project',
    )


```

Execution:

```bash
$ python script.py

That's my program!
usage: python -m project [options] [command]

command:
	help - see this cool msg again
	command1 - run handler for command1
	command2 - sum X and Y
		--x - arg x
		--y - arg y
	command3 - sum X and Y
		--x - arg x
		--y - arg y

```


```bash
$ python script.py command3 --x=123 --y=456
args.x=123
args.y=456
result: 579
```
