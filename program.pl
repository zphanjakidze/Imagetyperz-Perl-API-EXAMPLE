#!/bin/perl

use warnings;
use strict;
use ImageTypersAPI;

sub test_api
{	
	# set your own username and password
	# ----------------------------------
	my $username = 'user name here';
	my $password = 'password here';

	# recaptcha settings
	my $page_url = 'page url here';
	my $sitekey = 'key code here';

	# check account balance
	# ----------------------
	printf 'Balance: %s\n', ImageTypersAPI::account_balance($username, $password);
	
	# ==============================================================================
	# solve normal captcha
	# -------------------------
	# print 'Waiting for captcha to be solved ...';
	printf 'Captcha text: %s\n', ImageTypersAPI::solve_captcha($username, $password, 'captcha.jpg');

	# ==============================================================================
	# solve recaptcha
	# -------------------------
	# submit
	# -------
	my $captcha_id = ImageTypersAPI::submit_recaptcha($username, $password, $page_url, $sitekey);
	# retrieve
	# -------
	while(ImageTypersAPI::in_progress($username, $password, $captcha_id))	# while in progress
	{
		sleep(10);		# sleep for 10 seconds
	}
	printf 'Recaptcha response: %s\n', ImageTypersAPI::retrieve_recaptcha($username, $password, $captcha_id);
	
	# Other examples
	# ---------------------------------------------------------------------------------------------------------------------------------
	# ImageTypersAPI::solve_captcha($username, $password, "captcha.jpg", "1");		# with chkCase enabled
	# ImageTypersAPI::solve_captcha($username, $password, "captcha.jpg", "1", "123");		# with chkCase & refID
	
	# ImageTypersAPI::submit_recaptcha($username, $password, $page_url, $sitekey, '123');		# submit with refid
	# ImageTypersAPI::submit_recaptcha($username, $password, $page_url, $sitekey, '123', '127.0.0.1:8080', '1234');		# submit ref_id & proxy
	
	# ImageTypersAPI::retrieve_recaptcha($username, $password, $captcha_id, '123');				# with ref id	
	
	# ImageTypersAPI::set_captcha_bad($username, $password, $captcha_id);		# set captcha as bad
}

test_api();		# test API

1;
