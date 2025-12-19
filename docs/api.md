# Consumer API

This document describes the query parameter format for consumers of APIs built with Sift.

## Filtering

```
?filters[<field_name>]=<value>
```

Filters are translated to Active Record `where`s and are chained together. The order they are applied is not guaranteed.

### Examples

```
# Single filter
?filters[title]=hello

# Multiple filters
?filters[title]=hello&filters[status]=published

# Range filter
?filters[price]=10...50

# Array filter (for integer types)
?filters[id]=[1,2,3]
```

## Sorting

```
?sort=-published_at,position
```

Sort is translated to Active Record `order`. The sorts are applied in the order they are passed by the client.

The `-` prefix means to sort in `desc` order. By default, keys are sorted in `asc` order.

### Examples

```
# Single sort, ascending
?sort=title

# Single sort, descending
?sort=-created_at

# Multiple sorts
?sort=-published_at,title
```
