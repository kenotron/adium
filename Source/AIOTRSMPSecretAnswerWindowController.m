//
//  AIOTRSMPSecretAnswerWindowController.m
//  Adium
//
//  Created by Thijs Alkemade on 17-10-12.
//  Copyright (c) 2012 The Adium Team. All rights reserved.
//

#import "AIOTRSMPSecretAnswerWindowController.h"
#import <AIUtilities/AIImageAdditions.h>
#import <AIUtilities/AIAttributedStringAdditions.h>
#import <AIUtilities/AITextAttachmentAdditions.h>

@implementation AIOTRSMPSecretAnswerWindowController

- (id)initWithQuestion:(NSString *)inQuestion from:(AIListContact *)inContact completionHandler:(void(^)(NSData *answer, NSString *question))inHandler isInitiator:(BOOL)inInitiator
{
	if (self = [super initWithWindowNibName:@"AIOTRSMPSecretAnswerWindowController"]) {
		secretQuestion = inQuestion;
		contact = inContact;
		handler = inHandler;
		isInitiator = inInitiator;
	}
	
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	
	[imageView_lock setImage:[NSImage imageNamed:@"lock-locked" forClass:[adium class]]];
	
	path_file.URL = nil;
	
	if (isInitiator) {
		[label_intro setStringValue:[NSString stringWithFormat:AILocalizedString(@"Enter a question only %@ can answer correctly:", nil), contact.UID]];
		[label_answer setStringValue:AILocalizedString(@"Correct answer:", nil)];
		[label_tips setStringValue:[NSString stringWithFormat:AILocalizedString(@"Tips:\n"
																				@"• %@ will see the question and must give exactly the same answer to confirm their identity.\n"
																				@"• You can add \"in lowercase\" to your question to make it harder to make mistakes.\n"
																				@"• Make sure it is difficult for others to guess or find the answer.\n"
																				@"• Do not use your chat conversation to give the answer, even with encryption. You can give the answer over a different communication channel, for example phone or in person.", nil), contact.UID]];
	} else {
		[label_intro setStringValue:[NSString stringWithFormat:AILocalizedString(@"%@ asks you to answer the following secret question correctly to confirm your identity:", nil), contact.UID]];
		[label_answer setStringValue:AILocalizedString(@"Your answer:", nil)];
		[label_tips setStringValue:[NSString stringWithFormat:AILocalizedString(@"Tips:\n"
																				@"• Make sure you enter the answer exactly as %@ entered it.", nil), contact.UID]];

		
		NSAttributedString *question = [[NSAttributedString alloc] initWithString:secretQuestion ?: @""];
		
		[[field_question textStorage] setAttributedString:question];
		[field_question setEditable:NO];
	}
}

- (IBAction)okay:(id)sender
{
	NSData *answer = nil;
	
	if ([tab_answer indexOfTabViewItem:[tab_answer selectedTabViewItem]] == 0) {
		answer = [[[field_answer textStorage] string] dataUsingEncoding:NSUTF8StringEncoding];
	} else {
		answer = [NSData dataWithContentsOfURL:path_file.URL];
	}
	
	handler(answer, [[field_question textStorage] string]);
	
	[self.window close];
}

- (IBAction)cancel:(id)sender
{
	if (!isInitiator) handler(nil, nil);
	
	[self.window close];
}


- (IBAction)selectFile:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowsMultipleSelection:NO];
	
	NSInteger result = [openPanel runModal];
	
	if (result == NSOKButton && [openPanel URLs].count > 0) {
		path_file.URL = [[openPanel URLs] objectAtIndex:0];
	}
}

@end
