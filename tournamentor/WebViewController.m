//
//  WebViewController.m
//  tournamentor
//
//  Created by Zachary Mallicoat on 4/17/15.
//  Copyright (c) 2015 Zachary Mallicoat. All rights reserved.
//

#import "WebViewController.h"
#import <MBProgressHUD.h>
#import <SSKeychain/SSKeychain.h>
#import <SSKeychain/SSKeychainQuery.h>

@interface WebViewController () <UIWebViewDelegate, UIAlertViewDelegate>

@end

@implementation WebViewController{
    MBProgressHUD *_hud;
    User *user;
}

-(void)viewDidLoad {

    
    [super viewDidLoad];
    
    [self manualSignin];
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];

    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = @"Loading";
    
    UIBarButtonItem *signInButton = [[UIBarButtonItem alloc]
                                      initWithImage:[UIImage imageNamed:@"settings"]
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(manualSignin)];
    
    self.navigationItem.leftBarButtonItem = signInButton;


    NSString* url = @"https://challonge.com/settings/developer";

    NSURL* nsUrl = [NSURL URLWithString:url];
    self.webView.delegate = self;
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [self.webView loadRequest:request];



}

-(void)viewDidAppear:(BOOL)animated {
    [self performSegueWithIdentifier:@"manualSignin" sender:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)manualSignin {
    [self performSegueWithIdentifier:@"manualSignin" sender:self];
}

# pragma - Web View

- (void)webViewDidStartLoad:(UIWebView *)webView {

    [_hud show:YES];
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *errorLoading = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Error loading challonge.com. Check your network connection. Challonge could also be down." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorLoading show];
}



-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"Current URL %@", [webView stringByEvaluatingJavaScriptFromString:@"window.location"]);
    
    
    NSString *plainHTML = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSString *APIKEY = [self getAPIKey:plainHTML];
    NSString *USERNAME = [self getUsername:plainHTML];
    
    if (APIKEY.length == 40) {
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:nil forKey:@"ChallongeUsername"];
        [userDefaults setObject:nil forKey:@"ChallongeAPIKey"];
        
        
        
        [userDefaults setObject:USERNAME forKey:@"ChallongeUsername"];
        [userDefaults setObject:APIKEY forKey:@"ChallongeAPIKey"];
        
        NSString *completedDialog = [NSString stringWithFormat:@"%@, you are now signed into your Challonge account. hit OK to use Tournamentor.", USERNAME];
        
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Signed In"
                                                         message:completedDialog
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];

    }
    else {
        NSString *error = [self getError:plainHTML];
        
        if ([self.webView.request.URL.absoluteString isEqualToString:@"https://challonge.com/settings/developer"] && [error isEqualToString:@"API keys can only be issued to users with a verified email. Please verify your email address by following the link that was emailed to you. "]) {
        
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Email Verification Error"
                                                         message:@"Make sure you have verified your email address with Challonge.com, you can resend the verification e-mail by going to http://challonge.com/settings/developer and hitting \"send new link.\" Once you have done this, hit OK."
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        }
        else {
            NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"window.location"];
            
            if ([currentURL isEqualToString:@"http://challonge.com/settings/developers"]) {

            
            UIAlertView *error = [[UIAlertView alloc]initWithTitle:@"Error processing API Key" message:@"There was an error automatically processing your API key. Please enter your username and API key on the next screen. Grab your API Key by using the in app browser." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            error.tag = 101;
            
            
            [error show];
            }
        }
    }
    [_hud hide:YES];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 101) {
        [self manualSignin];
    } else {
    
    [self performSegueWithIdentifier:@"didGetApiKey" sender:self];
    }
}

# pragma helper methods



-(NSString *)getAPIKey:(NSString *)plainHTML
{
    NSString *key = @"";
    @try{
        NSScanner *scanner = [[NSScanner alloc] initWithString:plainHTML];
        [scanner scanUpToString:@"<code>" intoString:nil];
        [scanner scanString:@"<code>" intoString:nil];
        [scanner scanUpToString:@"</code>" intoString:&key];
    }
    @catch(NSException *ex)
    {}
    return key;
}

-(NSString *)getUsername:(NSString *)plainHTML {
    NSString *username = @"";
    
    @try {
        NSScanner *scanner = [[NSScanner alloc]initWithString:plainHTML];
        [scanner scanUpToString:@"<a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\">" intoString:nil];
        [scanner scanString:@"<a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\">" intoString:nil];
        [scanner scanUpToString:@"<b class=\"caret\">" intoString:&username];
    }
    @catch (NSException *exception) {}
    
    username = [username stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return username;
}

-(NSString *)getError:(NSString *)plainHTML {
    NSString *error = @"";
// <a data-method="post" href="/settings/resend_activation_key" rel="nofollow">Send a new link.</a>
    @try {
        NSScanner *scanner = [[NSScanner alloc]initWithString:plainHTML];
        [scanner scanUpToString:@"<div class=\"alert alert-danger\">" intoString:nil];
        [scanner scanString:@"<div class=\"alert alert-danger\">" intoString:nil];
        [scanner scanUpToString:@"<a data-method=\"post\" href=\"/settings/resend_activation_key\"" intoString:&error];
    }
    @catch (NSException *exception) {}
    
    error = [error stringByReplacingOccurrencesOfString:@"\n" withString:@""];
 
    return error;
}

@end
