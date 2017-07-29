#!/bin/perl

package ImageTypersAPI;

use warnings;
use strict;
use LWP::UserAgent;
use HTTP::Request::Common;
use MIME::Base64 qw(encode_base64);

# constants
# --------------------------------------------------------------------------------------------
my $CAPTCHA_ENDPOINT = 'http://captchatypers.com/Forms/UploadFileAndGetTextNEW.ashx';
my $RECAPTCHA_SUBMIT_ENDPOINT = 'http://captchatypers.com/captchaapi/UploadRecaptchaV1.ashx';
my $RECAPTCHA_RETRIEVE_ENDPOINT = 'http://captchatypers.com/captchaapi/GetRecaptchaText.ashx';
my $BALANCE_ENDPOINT = 'http://captchatypers.com/Forms/RequestBalance.ashx';
my $BAD_IMAGE_ENDPOINT = 'http://captchatypers.com/Forms/SetBadImage.ashx';

# Solve normal captcha
# -------------------------------------------------------------------------------------------------
sub solve_captcha
{
	my $ref_id = '0';
	my $chkcase = '0';
	
	my $ua = LWP::UserAgent->new();
	if(defined $_[3])		# check if chkcase was given
	{
		$chkcase = $_[3];	# set chkcase
	}
	if(defined $_[4])		# check if ref id was given
	{
		$ref_id = $_[4];	# set ref id
	}

	# read file
    local $/ = undef;
    open FILE, $_[2] or die "Couldn't open file: $!";
    my $string = <FILE>;
    close FILE;

	my $response = $ua->request(POST $CAPTCHA_ENDPOINT, Content => [
				 action => 'UPLOADCAPTCHA',
				 username => $_[0],
				 password => $_[1],
				 file => encode_base64($string),
				 chkCase => $chkcase,
				 refid => $ref_id
				]);

   	if ($response->is_error())
   	{
		return $response->status_line;
    } else {
		my $c = $response->content();
		return replace("Uploading file...", "", $c);
    }
}

# Submit recaptcha
# -------------------------------------------------------------------------------------------------
sub submit_recaptcha
{
	my $ua = LWP::UserAgent->new();
	my $proxy = '';
	my $proxy_type = '';
	my $ref_id = '0';
	
	if(defined $_[4])		# check if ref id was given
	{
		$ref_id = $_[4];	# set ref id
	}
	
	if(defined $_[5])		# check if proxy was given
	{
		$proxy = $_[5];	# proxy
	}
	else
	{
		$proxy = ''
	}
	
	if(defined $_[6])		# check if proxy type was given
	{
		$proxy_type = $_[6];	# proxy type (set)
	}
	else
	{
		$proxy_type = ''
	}

	my $response = $ua->request(POST $RECAPTCHA_SUBMIT_ENDPOINT, Content_Type => 'form-data', Content => [
				 action => 'UPLOADCAPTCHA',
				 username => $_[0],
				 password => $_[1],
				 pageurl =>$_[2],
				 googlekey => $_[3],
				 proxy => $proxy,
				 proxytype => $proxy_type,
				 refid => $ref_id
				]);

   	if ($response->is_error())
   	{
		return $response->status_line;
    } else {
        return $response->content();		# return ID
    }
}

# Retrieve recaptcha
# -------------------------------------------------------------------------------------------------
sub retrieve_recaptcha
{
	my $ref_id = '0';
	
	if(defined $_[3])		# check if ref id was given
	{
		$ref_id = $_[3];	# set ref id
	}
	my $ua = LWP::UserAgent->new();
	my $response = $ua->request(POST $RECAPTCHA_RETRIEVE_ENDPOINT, Content_Type => 'form-data', Content => [
				 action => 'GETTEXT',
				 username => $_[0],
				 password => $_[1],
				 captchaid => $_[2],
				 refid => $ref_id
				]);

   	if ($response->is_error())
   	{
		return $response->status_line;
    } else {
		return $response->content();
    }
}

# Checks if recaptcha is still in process of solving
sub in_progress
{
	my $resp = retrieve_recaptcha($_[0], $_[1], $_[2]);
	if(index($resp, 'NOT_DECODED') == -1)
	{
		return 0;		# does not contain NOT_DECODED, move on
	}
	else
	{
		return 1;		# contains NOT_DECODED, still in progress
	}
}

# Check account balance
# -------------------------------------------------------------------------------------------------
sub account_balance
{
	my $ua = LWP::UserAgent->new();
	my $response = $ua->request(POST $BALANCE_ENDPOINT, Content_Type => 'form-data', Content => [
				 action => 'REQUESTBALANCE',
				 username => $_[0],
				 password => $_[1],
				 'submit' => 'Submit'
				]);

    if ($response->is_error())
    {
		return $response->status_line;			# return error
    } else {
		return '$' . $response->content();		# return balance
    }
}

# Set captcha as BAD
sub set_captcha_bad
{
	my $ua = LWP::UserAgent->new();
	my $response = $ua->request(POST $BAD_IMAGE_ENDPOINT, Content_Type => 'form-data', Content => [
				 action => 'SETBADIMAGE',
				 username => $_[0],
				 password => $_[1],
				 imageid =>$_[2],
				 submit => "Submissssst"
				]);

   	if ($response->is_error())
   	{
		return $response->status_line;
    } else {
        return $response->content();		# return ID
    }
}

# replace string
sub replace {
	  my ($from,$to,$string) = @_;
	  $string =~s/$from/$to/ig;                          #case-insensitive/global (all occurrences)

	  return $string;
}

1;
