public inherited sharing class InstallHandler implements System.InstallHandler {
    public void onInstall(InstallContext context) {
        Version p = context.previousVersion();
        String s = 'Test App@0.1.0-<BuildVersion>';//p.major() + '.' + p.minor() + '.' + p.patch();
        MailUtils.send(
            context.installerId(),
            'Test App version (' + s + ') installed on ' + context.organizationId(),
            context.organizationId() + ' ' + context.installerId() + '<br/>' + context.isUpgrade() + ' ' 
            + context.isPush() + ( p != null ? ' previous version: ' + p.major() + ' ' + p.minor() + ' ' + p.patch() 
            : ' no previous version; fresh install')
        );
    } 
}