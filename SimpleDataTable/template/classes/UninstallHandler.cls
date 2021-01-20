public inherited sharing class UninstallHandler implements System.UninstallHandler {
    public void onUninstall(UninstallContext context) {
        String s = '<PackageName>@0.1.0-<BuildVersion>';
        
        MailUtils.send(
            context.uninstallerId(),
            '<PackageName> version (' + s + ') uninstalled on ' + context.organizationId(),
            context.organizationId() + ' ' + context.uninstallerId()
        );
        <PostUninstallCode>
    }
}