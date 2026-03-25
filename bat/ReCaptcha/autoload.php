<?php

/* An autoloader for ReCaptcha\Foo classes. This should be required()
 * by the user before attempting to instantiate any of the ReCaptcha
 * classes.
 */

spl_autoload_register(function ($class) {
    if (substr($class, 0, 10) !== 'ReCaptcha\\') {
      /* If the class does not lie under the "ReCaptcha" namespace,
       * then we can exit immediately.
       */
      return;
    }

    /* All of the classes have names like "ReCaptcha\Foo", so we need
     * to replace the backslashes with frontslashes if we want the
     * name to map directly to a location in the filesystem.
     */
    $class = str_replace('\\', '/', $class);

    /* First, check under the current directory. It is important that
     * we look here first, so that we don't waste time searching for
     * test classes in the common case.
     */
    $path = $class.'.php';
    if (is_readable($path)) {
        require_once $path;
    }
});


        <!-- whatsapp flutuante -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
        <a href="https://wa.me/5511971537112?text=Ol%C3%A1%20eu%20estava%20no%20site%20e%20gostaria%20de%20alugar%20itens%20para%20minha%20festa" class="whatsapp-float" target="_blank" rel="noopener" aria-label="Fale conosco pelo WhatsApp">
          <i style="margin-top:18px" class="fa fa-whatsapp"></i>
        </a>