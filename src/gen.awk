! /^\{.*/ {
	print $0
};

/^\{FROM\}/ {
	print "FROM " FROM " as base"
};

/^\{BASE\}/ {
	print BASE
};

/^\{BUILD\}/ {
	print BUILD
};
