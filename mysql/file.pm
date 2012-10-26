#!/usr/bin/perl
package file;
use Moose;
use utf8;
use Tie::File;
use Spreadsheet::DataFromExcel;
use File::Type;
use File::Basename;
use string;
use Data::Dumper;

has name => (is =>'rw');

sub _type {
	my $self=shift;
	my $filename=shift || $self->name;
	my $file_suffix={
		'.xls' => 1,
		'.text'=> 1,
		'.csv' => 1,
		'.xml' => 1,
		'.txt'  => 1,
	};
	my (undef,undef,$suffix)=fileparse($filename,qr/\.[^.]*/);
	return $suffix if $suffix && defined $file_suffix->{$suffix};
	my $type=File::Type->new;
	my $file_type=$type->checktype_filename($filename);
	return $file_type;
}

sub read {
	my $self=shift;
	my $filename=shift || $self->name;
	my $type = $self->_type;
	
	$type='.dir' if -d $filename;

	my $file_type = {
		'.xls' => \&_execl_read ,
		'.txt' => \&_array_read ,
		'.text' => \&_array_read,
		'csv'  => undef,
		'.dir' => \&_dir_read,
	};

	unless (-e $filename ){
		$self->error("$filename : 不存在");
		return 0;
	}
	unless ($type){
		$self->error("$filename : 未知类型");
		return 0;
	}
	my $data=&{$file_type->{$type}}($filename);
	unless($data){
		$self->error("$filename : 读取文件失败");
		return 0;
	}
	unless(ref $data eq 'HASH' || ref $data eq 'ARRAY'){
		$self->error($data);
		return 0;
	}
	
	return $data;

}

sub _execl_read {
	my $file=shift;
	my $execl=Spreadsheet::DataFromExcel->new;
	print $file,"\n";
	my $file_content=$execl->load($file);
	$file_content ? return $file_content : return $execl->error;


}
sub _array_read {
        my $file=shift;
        my @data;
        tie(@data,'Tie::File',$file,autochomp => 1);
        @data ? return \@data : return "打开 $file 失败";
}
sub _dir_read {
	my $dir=shift;
	opendir(my $dh, $dir) || return  "can't opendir $dir: $!";
    	my @dir =  readdir($dh);
    	closedir $dh;
	return \@dir;
}
1
