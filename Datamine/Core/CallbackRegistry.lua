local registry = CreateFromMixins(CallbackRegistryMixin);

function registry.RunAfterAddonLoad(func, ...)
    assert(type(func) == "function", "bro");
    EventUtil.ContinueOnAddOnLoaded("Datamine", GenerateClosure(func, ...));
end