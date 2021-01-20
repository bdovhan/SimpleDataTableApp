public inherited sharing class UninstallHandler implements System.UninstallHandler {
    public void onUninstall(UninstallContext context) {
        String s = 'Test App@0.1.0-<BuildVersion>';
        
        MailUtils.send(
            context.uninstallerId(),
            'Test App version (' + s + ') uninstalled on ' + context.organizationId(),
            context.organizationId() + ' ' + context.uninstallerId()
        );
    }
}