
#!/bin/bash

#
# migrate and format all cairo files in project/dir
# oneline: `for i in $(find . -name "*.cairo" -type f); do cairo-migrate $i -i; done`
#
for i in $(find . -name "*.cairo" -type f); do
    echo "editing $i"
    cairo-migrate -i $i
done
