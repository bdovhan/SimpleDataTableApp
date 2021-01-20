public inherited sharing class InstallHandler implements System.InstallHandler {
    public void onInstall(InstallContext context) {
        Version p = context.previousVersion();
        String s = '<PackageName>@0.1.0-<BuildVersion>';
        MailUtils.send(
            context.installerId(),
            '<PackageName> version (' + s + ') installed on ' + context.organizationId(),
            context.organizationId() + ' ' + context.installerId() + '<br/>' + context.isUpgrade() + ' ' 
            + context.isPush() + ( p != null ? ' previous version: ' + p.major() + ' ' + p.minor() + ' ' + p.patch() 
            : ' no previous version; fresh install')
        );
        <PostInstallCode>
    } 
}