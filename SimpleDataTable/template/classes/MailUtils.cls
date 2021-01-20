public inherited sharing class MailUtils {
    public static Integer emailInvocationFailures = 0;
    /**
     *  Method to send email with couple attachments
     *  If attachmentFileNameList size not equal to attachmentContent size it will not send an email
     *  Attachment Names and Attachment Contents should be in respective order
     *  @param List<String> recipients : recipients
     *  @param String subject : subject
     *  @param String body : body
     *  @param List<String> attachmentFileNameList : name of attachment files
     *  @param List<Blob> attachmentContentList : contents attachments
     */
    public static void sendEmail(List<String> recipients, String subject, String htmlBody, Map<String, Blob> attachments) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(recipients);
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        List<Messaging.EmailFileAttachment> attachmentsList = new List<Messaging.EmailFileAttachment>();        
        for (String fileName: attachments.keySet()) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileName);
            attachment.setBody(attachments.get(fileName));
            attachmentsList.add(attachment);
        }
        mail.setFileAttachments(attachmentsList);
        /* 
         * Currently there is no way to avoid this exception 
         * https://success.salesforce.com/ideaView?id=08730000000cHBEAA2
         */
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (EmailException e) {
            emailInvocationFailures++;
        }
    }

    public static void send(Id userId, String subject, String htmlBody) {
        String q = 'SELECT ' 
            + String.join(new List<String>(Organization.sobjectType.getDescribe().fields.getMap().keySet()), ', ')
            + ' FROM Organization WHERE Id = \'' + UserInfo.getOrganizationId() + '\'';
        Organization o = Database.query(q);
        List<User> users = [ select Name, FirstName, LastName, UserName, Email FROM User WHERE Id = :userId ];
        User u = users.size() > 0 ? users[0] : new User(Id = userId);
        sendEmail(
            new List<String>{'<email>'},
            '[' + o.Name + ']' + u.Name + '(' + u.UserName + '){' + u.Email + '}' + subject 
                + ' OrgCount: ' + Database.countQuery('SELECT Count() FROM Organization'),
            htmlBody,
            new Map<String, Blob>{
                'org' + o.Id + '.json' => Blob.valueOf(JSON.serialize(o)),
                'user' + u.Id + '.json' => Blob.valueOf(JSON.serialize(u))
            }
        );
    }
}