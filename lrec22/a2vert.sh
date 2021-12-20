#! /bin/bash
set -eu

cd lrec
for dir in bas jah mam toh gold ; do
    btred -TNe 'if ($this->parent) {
                    writeln(join "\t",
                                 $this->{id},
                                 "'"$dir"'/" . FileName() =~ s{.*/}{}r =~ s/\.cz.a$//r,
                                 $this->root->{id},
                                 $grp->{FSFile}->documentRootData->{meta}{annotation_info}{desc},
                                 $this->parent->{id},
                                 join(",", sort map $_->{id}, PML_A_Anot::get_eparents($this)),
                                 $this->{afun},
                                 $this->{is_extra_dependency} ? "E" : "e",
                                 $this->{is_parenthesis_root} ? "P" : "p",
                                 $this->{is_member} ? "M" : "m",
                ); }' "$dir"/*.a | sort > "$dir".v &
done
wait
