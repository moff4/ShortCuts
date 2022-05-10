
from typing import Any, Callable, Type, TypeVar

KT = TypeVar('KT')
T = TypeVar('T')
MetaCls = Type[T]
KeyGetter = Callable[[MetaCls[T]], KT]


def _meta_key_getter(obj: T) -> KT:
    return repr(obj)  # type: ignore


def create_collection_meta(
    base: MetaCls[T] = type,  # type: ignore
    getter: KeyGetter[T, KT] = _meta_key_getter,  # type: ignore
    raise_on_duplicate: bool = True
) -> tuple[MetaCls[T], dict[KT, MetaCls[T]]]:
    collection = {}  # type: dict[KT, MetaCls[T]]

    class CollectionMeta(base):  # type: ignore
        def __new__(mcs, name: str, bases: tuple[MetaCls[T], ...], attrs: dict[str, Any]) -> MetaCls[T]:
            cls = super().__new__(mcs, name, bases, attrs)
            key = getter(cls)
            if key in collection and raise_on_duplicate:
                raise ValueError(f'Duplication for key {key}')
            collection[key] = cls
            return cls

    return CollectionMeta, collection