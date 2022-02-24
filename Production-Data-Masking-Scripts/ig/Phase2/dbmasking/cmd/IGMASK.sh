#!/usr/bin/ksh

/opt/ig/dbmasking/sql/Parent.sh

if [ ${?} -eq 1 ]; then
echo "Error occured in Parent.sh"
exit 1
fi

/opt/ig/hitoku/user/bin/DataMasking_ALL.sh

if [ ${?} -eq 1 ]; then
echo "Error occured in DataMasking_ALL.sh"
exit 1
fi

/opt/ig/dbmasking/sql/ParentLoader.sh

if [ ${?} -eq 1 ]; then
echo "Error occured in ParentLoader.sh"
exit 1
fi

exit 0

/opt/ig/dbmasking/sql/Parent_move.sh

if [ ${?} -eq 1 ]; then
echo "Error occured in Parent_move.sh"
exit 1
fi


exit 0
