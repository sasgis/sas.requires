        ��  ��                  $� H   ��
 D E V T O O L S / D E B U G G E R . J S         0	        / /   o r i g i n a l   F i r e F o x   i m p l e m e n t a t i o n   i s   i n :   
 / /   g i t   c l o n e   h t t p s : / / g i t h u b . c o m / m o z i l l a / g e c k o - d e v . g i t   
 / /   c d   g e c k o - d e v / d e v t o o l s / s e r v e r     
 / /   F F   d e b u g g e r   P r o t o c o l :   h t t p s : / / s e a r c h f o x . o r g / m o z i l l a - c e n t r a l / s o u r c e / d e v t o o l s / d o c s / b a c k e n d / p r o t o c o l . m d 
 i m p o r t   *   a s   D e v T o o l s U t i l s   f r o m   ' D e v T o o l s / D e v T o o l s U t i l s . j s ' ;   
 i m p o r t   { J S P r o p e r t y P r o v i d e r }   f r o m   ' D e v T o o l s / j s - p r o p e r t y - p r o v i d e r . j s ' ;   
 i m p o r t   { O b j e c t A c t o r P r e v i e w e r s }   f r o m   ' D e v T o o l s / O b j e c t A c t o r P r e v i e w e r s . j s ' ;   
 i m p o r t   { s t r i n g i f y }   f r o m   ' D e v T o o l s / s t r i n g i f y . j s ' ;   
   
 l e t   a c t o r M a n a g e r   =   n u l l ,   
         d b g _ b i n d i n g   =   p r o c e s s . b i n d i n g ( ' d e b u g g e r ' ) ;   
   
 c o n s t   L O N G _ S T R I N G _ I N I T I A L _ L E N G T H   =   1 0 0 0 ;   
   
 c l a s s   A c t o r M a n a g e r   {   
         c o n s t r u c t o r ( t h r e a d I D )   {   
                 t h i s . t h r e a d I D   =   t h r e a d I D ;   
         }   
         i n i t ( ) {   
                 t h i s . c o n s o l e   =   n e w   C o n s o l e A c t o r ( ' c o n s o l e '   +   t h i s . t h r e a d I D ) ;   
                 t h i s . a d d o n   =   n e w   A d d o n A c t o r ( ' t h r e a d _ '   +   d b g _ b i n d i n g . t h r e a d I d ) ;   
         }   
         g e t A c t o r ( a c t o r N a m e ) {   
                 l e t   a c t o r   =   t h i s ;   
                 a c t o r N a m e . s p l i t ( ' . ' ) . f o r E a c h ( f u n c t i o n ( e l e m ) {   
                         i f   ( a c t o r )   
                                 a c t o r   =   a c t o r [ e l e m ] ;   
                 } ) ;   
                 r e t u r n   a c t o r ;   
         }   
 }   
   
 c l a s s   A c t o r   {   
         c o n s t r u c t o r   ( a c t o r N a m e ,   p a r e n t )   {   
                 p a r e n t   =   p a r e n t   ?   p a r e n t   :   a c t o r M a n a g e r ;   
                 t h i s . _ a c t o r   =   a c t o r N a m e ;   
                 t h i s . _ p a r e n t   =   p a r e n t ;   
                 t h i s . _ g r i p s   =   0 ;   
                 t h i s . _ g r i p D e p t h   =   0 ;   
                 p a r e n t [ a c t o r N a m e ]   =   t h i s ;   
         }   
         g e t   f u l l A c t o r ( )   {   
                 l e t   r e s   =   t h i s . _ p a r e n t . f u l l A c t o r ;   
                 r e t u r n   r e s   ?   r e s   +   ' . '   +   t h i s . _ a c t o r   :   t h i s . _ a c t o r ;   
         }   
         g e t G r i p ( v a l u e )   {   
                 v a r   t y p e   =   t y p e o f ( v a l u e ) ;   
                 i f   ( t y p e   = = =   " b o o l e a n " )   
                         r e t u r n   v a l u e ;   
                 i f   ( t y p e   = = =   " n u m b e r " )   {   
                         i f   ( v a l u e   = = =   I n f i n i t y )   {   
                                 r e t u r n   {   t y p e :   " I n f i n i t y "   } ;   
                         }   e l s e   i f   ( v a l u e   = = =   - I n f i n i t y )   {   
                                 r e t u r n   {   t y p e :   " - I n f i n i t y "   } ;   
                         }   e l s e   i f   ( N u m b e r . i s N a N ( v a l u e ) )   {   
                                 r e t u r n   {   t y p e :   " N a N "   } ;   
                         }   e l s e   i f   ( 1   /   v a l u e   = = =   - I n f i n i t y )   {   
                                 r e t u r n   {   t y p e :   " - 0 "   } ;   
                         }   
                         r e t u r n   v a l u e ;   
                 }   
                 i f   ( t y p e   = = =   " s t r i n g " )   {   
                         i f   ( v a l u e . l e n g t h   >   L O N G _ S T R I N G _ I N I T I A L _ L E N G T H )   
                                 r e t u r n   ( n e w   L S t r A c t o r ( v a l u e ,   t h i s ) ) . _ r e s p ;   
                         e l s e   
                                 r e t u r n   v a l u e ;   
                 }   
                 i f   ( t y p e   = = =   " u n d e f i n e d " )   
                         r e t u r n   {   t y p e :   " u n d e f i n e d "   } ;   
                 i f   ( t y p e   = = =   " o b j e c t " )   {   
                         i f   ( v a l u e   = = =   n u l l )   {   
                                 r e t u r n   {   t y p e :   " n u l l "   } ;   
                         }   
                         i f   ( v a l u e . o p t i m i z e d O u t   | |   
                                 v a l u e . u n i n i t i a l i z e d   | |   
                                 v a l u e . m i s s i n g A r g u m e n t s )   {   
                                 / /   T h e   s l o t   i s   o p t i m i z e d   o u t ,   a n   u n i n i t i a l i z e d   b i n d i n g ,   o r   
                                 / /   a r g u m e n t s   o n   a   d e a d   s c o p e   
                                 r e t u r n   {   
                                         t y p e :   " n u l l " ,   
                                         o p t i m i z e d O u t :   v a l u e . o p t i m i z e d O u t ,   
                                         u n i n i t i a l i z e d :   v a l u e . u n i n i t i a l i z e d ,   
                                         m i s s i n g A r g u m e n t s :   v a l u e . m i s s i n g A r g u m e n t s   
                                 } ;   
                         }   
                         r e t u r n   ( n e w   O b j e c t A c t o r ( v a l u e ,   t h i s ) ) . _ r e s p ;   
                 }   
                 i f   ( t y p e   = = =   " s y m b o l " )   {   
                         l e t   f o r m   =   {   
                                 t y p e :   " s y m b o l "   
                         } ;   
                         l e t   n a m e   =   g e t S y m b o l N a m e ( v a l u e ) ;   
                         i f   ( n a m e   ! = =   u n d e f i n e d )   {   
                                 f o r m . n a m e   =   t h i s . g e t G r i p ( n a m e ) ;   
                         }   
                         r e t u r n   f o r m ;   
                 }   
                 t h r o w   n e w   E r r o r ( ' g e t G r i p   f a i l e d :   '   +   t y p e   +   '   :   '   +   v a l u e ) ;   
                 / / r e t u r n   n u l l ;   
         }   
         c r e a t e P r o t o c o l C o m p l e t i o n V a l u e ( a C o m p l e t i o n )   {   
                 l e t   p r o t o V a l u e   =   { } ;   
                 i f   ( a C o m p l e t i o n   = =   n u l l )   {   
                         p r o t o V a l u e . t e r m i n a t e d   =   t r u e ;   
                 }   e l s e   i f   ( " r e t u r n "   i n   a C o m p l e t i o n )   {   
                         p r o t o V a l u e . r e t u r n   =   t h i s . g e t G r i p ( a C o m p l e t i o n . r e t u r n ) ;   
                 }   e l s e   i f   ( " t h r o w "   i n   a C o m p l e t i o n )   {   
                         p r o t o V a l u e . t h r o w   =   t h i s . g e t G r i p ( a C o m p l e t i o n . t h r o w ) ;   
                 }   e l s e   {   
                         p r o t o V a l u e . r e t u r n   =   t h i s . g e t G r i p ( a C o m p l e t i o n . y i e l d ) ;   
                 }   
                 r e t u r n   p r o t o V a l u e ;   
         }   
 }   
   
 c o n s t   s y m b o l P r o t o T o S t r i n g   =   S y m b o l . p r o t o t y p e . t o S t r i n g ;   
 f u n c t i o n   g e t S y m b o l N a m e ( s y m b o l )   {   
     c o n s t   n a m e   =   s y m b o l P r o t o T o S t r i n g . c a l l ( s y m b o l ) . s l i c e ( " S y m b o l ( " . l e n g t h ,   - 1 ) ;   
     r e t u r n   n a m e   | |   u n d e f i n e d ;   
 }   
   
 c l a s s   C o n s o l e A c t o r   e x t e n d s   A c t o r   {   
         c o n s t r u c t o r   ( a c t o r N a m e )   {   
                 s u p e r ( a c t o r N a m e ) ;   
                 t h i s . w e l c o m e S h o w e d   =   f a l s e ;   
   
                 t h i s . c o n s o l e C o m m a n d s   =   {   
                         h e l p :   " W e l c o m e   t o   S M   d e b u g g e r   c o n s o l e " ,   
                         t e s t :   {   
                                 c o m m a n d :   f u n c t i o n ( ) {   
                                         r e t u r n   ' ! ! ! t e s t   c a l l e d ! ! ! ' ;   
                                 } ,   
                                 d e s c r i p t i o n :   " T e s t   f u n c t i o n   f o r   d e b u g g e r .   R e t u r n s   ' ! ! ! t e s t   c a l l e d ! ! ! ' "   
                         }   
                 }   
   
         }   
         s t a r t L i s t e n e r s ( a R e q u e s t )   {   
                 r e t u r n   {   
                         " s t a r t e d L i s t e n e r s " :   [ " C o n s o l e A P I " ] ,   
                         " n a t i v e C o n s o l e A P I " :   t r u e ,   
                         " t r a i t s " :   { e v a l u a t e J S A s y n c :   t r u e }   
                 } ;   
         }   
         s t o p L i s t e n e r s ( a R e q u e s t )   {   
                 t h i s . w e l c o m e S h o w e d   =   f a l s e ;   
                 r e t u r n   {   
                         s t o p p e d L i s t e n e r s :   [ ]   
                 }   
         }   
         s e t P r e f e r e n c e s ( a R e q u e s t )   {   
                 r e t u r n   {   u p d a t e d :   O b j e c t . k e y s ( a R e q u e s t . p r e f e r e n c e s )   } ;   
         }   
         g e t C a c h e d M e s s a g e s ( a R e q u e s t )   {   
                 i f ( ! t h i s . w e l c o m e S h o w e d )   {   
                         n e w C o n s o l e M e s s a g e ( ` C o n n e c t e d . . .   T y p e   ?   f o r   h e l p ` ) ;   
                         t h i s . w e l c o m e S h o w e d   =   t r u e ;   
                 }   
                 r e t u r n   {   
                         m e s s a g e s :   [ ]   
                 } ;   
         }   
         e v a l u a t e J S ( a R e q u e s t )   {   
                 l e t   i n p u t   =   a R e q u e s t . t e x t ;   
                 l e t   t i m e s t a m p   =   D a t e . n o w ( ) ;   
   
                 l e t   e v a l O p t i o n s   =   {   
                         b i n d O b j e c t A c t o r :   a R e q u e s t . b i n d O b j e c t A c t o r ,   
                         f r a m e A c t o r :   a R e q u e s t . f r a m e A c t o r ,   
                         u r l :   a R e q u e s t . u r l ,   
                         s e l e c t e d N o d e A c t o r :   a R e q u e s t . s e l e c t e d N o d e A c t o r ,   
                         s e l e c t e d O b j e c t A c t o r :   a R e q u e s t . s e l e c t e d O b j e c t A c t o r   
                 } ;   
   
                 l e t   e v a l I n f o   =   t h i s . _ e v a l W i t h D e b u g g e r ( i n p u t ,   e v a l O p t i o n s ) ;   
                 l e t   e v a l R e s u l t   =   e v a l I n f o . r e s u l t ;   
                 / / l e t   h e l p e r R e s u l t   =   e v a l I n f o . h e l p e r R e s u l t ;   
   
                 l e t   r e s u l t ,   e r r o r M e s s a g e ,   e r r o r G r i p   =   n u l l ;   
                 i f   ( e v a l R e s u l t )   {   
                         i f   ( " r e t u r n "   i n   e v a l R e s u l t )   {   
                                 r e s u l t   =   e v a l R e s u l t . r e t u r n ;   
                         }   e l s e   i f   ( " y i e l d "   i n   e v a l R e s u l t )   {   
                                 r e s u l t   =   e v a l R e s u l t . y i e l d ;   
                         }   e l s e   i f   ( " t h r o w "   i n   e v a l R e s u l t )   {   
                                 l e t   e r r o r   =   e v a l R e s u l t . t h r o w ;   
                                 e r r o r G r i p   =   t h i s . g e t G r i p ( e r r o r ) ;   
 	 	 	 	 e r r o r M e s s a g e   =   S t r i n g ( e r r o r ) ;     
 	 	 	 	   
 	 	 	 	 i f   ( t y p e o f   e r r o r   = = =   " o b j e c t "   & &   e r r o r   ! = =   n u l l )   {   
 	 	 	 	     t r y   {   
 	 	 	 	 	 e r r o r M e s s a g e   =   D e v T o o l s U t i l s . c a l l P r o p e r t y O n O b j e c t ( e r r o r ,   " t o S t r i n g " ) ;   
 	 	 	 	     }   c a t c h   ( e )   {   
 	 	 	 	 	 / /   I f   t h e   d e b u g g e e   i s   n o t   a l l o w e d   t o   a c c e s s   t h e   " t o S t r i n g "   p r o p e r t y   
 	 	 	 	 	 / /   o f   t h e   e r r o r   o b j e c t ,   c a l l i n g   t h i s   p r o p e r t y   f r o m   t h e   d e b u g g e e ' s   
 	 	 	 	 	 / /   c o m p a r t m e n t   w i l l   f a i l .   T h e   d e b u g g e r   s h o u l d   s h o w   t h e   e r r o r   o b j e c t   
 	 	 	 	 	 / /   a s   i t   i s   s e e n   b y   t h e   d e b u g g e e ,   s o   t h i s   b e h a v i o r   i s   c o r r e c t .   
 	 	 	 	 	 / /   
 	 	 	 	 	 / /   U n f o r t u n a t e l y ,   w e   h a v e   a t   l e a s t   o n e   t e s t   t h a t   a s s u m e s   c a l l i n g   t h e   
 	 	 	 	 	 / /   " t o S t r i n g "   p r o p e r t y   o f   a n   e r r o r   o b j e c t   w i l l   s u c c e e d   i f   t h e   
 	 	 	 	 	 / /   d e b u g g e r   i s   a l l o w e d   t o   a c c e s s   i t ,   r e g a r d l e s s   o f   w h e t h e r   t h e   
 	 	 	 	 	 / /   d e b u g g e e   i s   a l l o w e d   t o   a c c e s s   i t   o r   n o t .   
 	 	 	 	 	 / /   
 	 	 	 	 	 / /   T o   a c c o m o d a t e   t h e s e   t e s t s ,   i f   c a l l i n g   t h e   " t o S t r i n g "   p r o p e r t y   
 	 	 	 	 	 / /   f r o m   t h e   d e b u g g e e   c o m p a r t m e n t   f a i l s ,   w e   r e w r a p   t h e   e r r o r   o b j e c t   
 	 	 	 	 	 / /   i n   t h e   d e b u g g e r ' s   c o m p a r t m e n t ,   a n d   t h e n   c a l l   t h e   " t o S t r i n g "   
 	 	 	 	 	 / /   p r o p e r t y   f r o m   t h e r e .   
 	 	 	 	 	 i f   ( t y p e o f   e r r o r . u n s a f e D e r e f e r e n c e   = = =   " f u n c t i o n " )   {   
 	 	 	 	 	     e r r o r M e s s a g e   =   e r r o r . u n s a f e D e r e f e r e n c e ( ) . t o S t r i n g ( ) ;   
 	 	 	 	 	 }   
 	 	 	 	     } 	 	 	 	   
 	 	 	 	 }       
 / * 	 	 	 	   
                                 / /   X X X w o r k e r s :   C a l l i n g   u n s a f e D e r e f e r e n c e ( )   r e t u r n s   a n   o b j e c t   w i t h   n o   
                                 / /   t o S t r i n g   m e t h o d   i n   w o r k e r s .   S e e   B u g   1 2 1 5 1 2 0 .   
                                 l e t   u n s a f e D e r e f e r e n c e   =   e r r o r   & &   ( t y p e o f   e r r o r   = = =   " o b j e c t " )   & &   
                                         e r r o r . u n s a f e D e r e f e r e n c e ( ) ;   
                                 e r r o r M e s s a g e   =   u n s a f e D e r e f e r e n c e   & &   u n s a f e D e r e f e r e n c e . t o S t r i n g   
                                         ?   u n s a f e D e r e f e r e n c e . t o S t r i n g ( )   
                                         :   " "   +   e r r o r ;   
 * / 	   
                         }   
                 }   
   
                 / /   I f   a   v a l u e   i s   e n c o u n t e r e d   t h a t   t h e   d e b u g g e r   s e r v e r   d o e s n ' t   s u p p o r t   y e t ,   
                 / /   t h e   c o n s o l e   s h o u l d   r e m a i n   f u n c t i o n a l .   
                 l e t   r e s u l t G r i p ;   
                 t r y   {   
                         / / r e s u l t G r i p   =   r e s u l t   = = =   u n d e f i n e d   ?   r e s u l t   :   t h i s . g e t G r i p ( r e s u l t ) ;   
                         r e s u l t G r i p   =   r e s u l t   = = =   u n d e f i n e d   ?   r e s u l t   :   ( a R e q u e s t . f r a m e A c t o r   ?   a c t o r M a n a g e r . g e t A c t o r ( a R e q u e s t . f r a m e A c t o r )   :   t h i s ) . g e t G r i p ( r e s u l t ) ;   
   
                 }   c a t c h   ( e )   {   
                         e r r o r M e s s a g e   =   e ;   
                 }   
   
                 t h i s . _ l a s t C o n s o l e I n p u t E v a l u a t i o n   =   r e s u l t ;   
   
                 r e t u r n   {   
                         i n p u t :   i n p u t ,   
                         r e s u l t :   r e s u l t G r i p ,   
                         t i m e s t a m p :   t i m e s t a m p ,   
                         e x c e p t i o n :   e r r o r G r i p ,   
                         e x c e p t i o n M e s s a g e :   e r r o r M e s s a g e = = = u n d e f i n e d   ?   e r r o r M e s s a g e   :   t h i s . g e t G r i p ( e r r o r M e s s a g e ) ,   
                         / / h e l p e r R e s u l t :   h e l p e r R e s u l t   
                         h e l p e r R e s u l t :   n u l l   
                 } ;   
   
         }   
         e v a l u a t e J S A s y n c ( a R e q u e s t )   {   
                 / /   W e   w a n t   t o   b e   a b l e   t o   r u n   c o n s o l e   c o m m a n d s   w i t h o u t   w a i t i n g   
                 / /   f o r   t h e   f i r s t   t o   r e t u r n   ( s e e   B u g   1 0 8 8 8 6 1 ) .   
   
                 / /   F i r s t ,   s e n d   a   r e s p o n s e   p a c k e t   w i t h   t h e   i d   o n l y .   
                 l e t   r e s u l t I D   =   D a t e . n o w ( ) ;   
                 d b g _ b i n d i n g . s e n d ( {   
                         f r o m :   t h i s . f u l l A c t o r ,   
                         r e s u l t I D :   r e s u l t I D   
                 } ) ;   
   
                 / /   T h e n ,   e x e c u t e   t h e   s c r i p t   t h a t   m a y   p a u s e .   
                 l e t   r e s p o n s e   =   t h i s . e v a l u a t e J S ( a R e q u e s t ) ;   
                 r e s p o n s e . r e s u l t I D   =   r e s u l t I D ;   
   
                 r e s p o n s e . t y p e   =   " e v a l u a t i o n R e s u l t " ;   
   
                 r e t u r n   r e s p o n s e ;   
         }   
         _ e v a l W i t h D e b u g g e r ( a S t r i n g ,   a O p t i o n s   =   { } ) {   
                 l e t   t r i m m e d S t r i n g   =   a S t r i n g . t r i m ( ) ;   
                 / /   T h e   h e l p   f u n c t i o n   n e e d s   t o   b e   e a s y   t o   g u e s s ,   s o   w e   m a k e   t h e   ( )   o p t i o n a l .   
                 i f   ( t r i m m e d S t r i n g   = =   " h e l p "   | |   t r i m m e d S t r i n g   = =   " ? " )   {   
                         a S t r i n g   =   " h e l p ( ) " ;   
                 }   
   
                 / /   A d d   e a s t e r   e g g   f o r   c o n s o l e . m i h a i ( ) .   
                 i f   ( t r i m m e d S t r i n g   = =   " c o n s o l e . m i h a i ( ) "   | |   t r i m m e d S t r i n g   = =   " c o n s o l e . m i h a i ( ) ; " )   {   
                         a S t r i n g   =   " \ " h t t p : / / i n c o m p l e t e n e s s . m e / b l o g / 2 0 1 5 / 0 2 / 0 9 / c o n s o l e - d o t - m i h a i / \ " " ;   
                 }   
   
                 / /   F i n d   t h e   D e b u g g e r . F r a m e   o f   t h e   g i v e n   F r a m e A c t o r .   
                 l e t   f r a m e   =   n u l l ,   f r a m e A c t o r   =   n u l l ;   
                 i f   ( a O p t i o n s . f r a m e A c t o r )   {   
                         f r a m e A c t o r   =   a c t o r M a n a g e r . g e t A c t o r ( a O p t i o n s . f r a m e A c t o r ) ;   
                         i f   ( f r a m e A c t o r )   {   
                                 f r a m e   =   f r a m e A c t o r . _ f r a m e ;   
                         }   
                         e l s e   {   
                                 D e v T o o l s U t i l s . r e p o r t E x c e p t i o n ( " e v a l W i t h D e b u g g e r " ,   
                                         E r r o r ( " T h e   f r a m e   a c t o r   w a s   n o t   f o u n d :   "   +   a O p t i o n s . f r a m e A c t o r )   
                                 ) ;   
                         }   
                 }   
   
                 / /   I f   w e ' v e   b e e n   g i v e n   a   f r a m e   a c t o r   i n   w h o s e   s c o p e   w e   s h o u l d   e v a l u a t e   t h e   
                 / /   e x p r e s s i o n ,   b e   s u r e   t o   u s e   t h a t   f r a m e ' s   D e b u g g e r   ( t h a t   i s ,   t h e   J a v a S c r i p t   
                 / /   d e b u g g e r ' s   D e b u g g e r )   f o r   t h e   w h o l e   o p e r a t i o n ,   n o t   t h e   c o n s o l e ' s   D e b u g g e r .   
                 / /   ( O n e   D e b u g g e r   w i l l   t r e a t   a   d i f f e r e n t   D e b u g g e r ' s   D e b u g g e r . O b j e c t   i n s t a n c e s   
                 / /   a s   o r d i n a r y   o b j e c t s ,   n o t   a s   r e f e r e n c e s   t o   b e   f o l l o w e d ,   s o   m i x i n g   
                 / /   d e b u g g e r s   c a u s e s   s t r a n g e   b e h a v i o r s . )   
                 / / l e t   d b g   =   f r a m e   ?   f r a m e A c t o r . t h r e a d A c t o r . d b g   :   t h i s . d b g ;   
                 l e t   d b g   =   a c t o r M a n a g e r . t h r e a d . d b g ;   
                 l e t   d b g W i n d o w   =   d b g . m a k e G l o b a l O b j e c t R e f e r e n c e ( d b g _ b i n d i n g . g l o b a l ) ;   
   
                 / /   I f   w e   h a v e   a n   o b j e c t   t o   b i n d   t o   | _ s e l f | ,   c r e a t e   a   D e b u g g e r . O b j e c t   
                 / /   r e f e r r i n g   t o   t h a t   o b j e c t ,   b e l o n g i n g   t o   d b g .   
                 l e t   b i n d S e l f   =   n u l l ;   
                 i f   ( a O p t i o n s . b i n d O b j e c t A c t o r   | |   a O p t i o n s . s e l e c t e d O b j e c t A c t o r )   {   
                         / / t h r o w   n e w   E r r o r ( ' t o d o ' + a S t r i n g + ' | ' + J S O N . s t r i n g i f y ( a O p t i o n s ) ) ;   
                         l e t   o b j A c t o r   =   a c t o r M a n a g e r . g e t A c t o r ( a O p t i o n s . b i n d O b j e c t A c t o r   | |   a O p t i o n s . s e l e c t e d O b j e c t A c t o r ) ;   
                         i f   ( o b j A c t o r )   {   
                                 l e t   j s O b j   =   o b j A c t o r . _ o b j . u n s a f e D e r e f e r e n c e ( ) ;   
                                 b i n d S e l f   =   d b g . f i n d A l l G l o b a l s ( ) [ 0 ] . m a k e D e b u g g e e V a l u e ( j s O b j ) ;   
                         }   
                 }   
                 l e t   b i n d i n g s   =   { } ,   
                         c o m m a n d ,   
                         r e s   =   [ ] ,   
                         m a x l e n   =   0 ;   
   
   
                 f o r   ( c o m m a n d   i n   t h i s . c o n s o l e C o m m a n d s )   {   
                         i f   ( c o m m a n d   ! = =   ' h e l p '   & &   t h i s . c o n s o l e C o m m a n d s [ c o m m a n d ] . c o m m a n d )   {   
                                 b i n d i n g s [ c o m m a n d ]   =   d b g . f i n d A l l G l o b a l s ( ) [ 0 ] . m a k e D e b u g g e e V a l u e ( t h i s . c o n s o l e C o m m a n d s [ c o m m a n d ] . c o m m a n d ) ;   
                                 l e t   _ c o m m a n d   =   t y p e o f   t h i s . c o n s o l e C o m m a n d s [ c o m m a n d ] . c o m m a n d   = = =   ' f u n c t i o n '   ?   c o m m a n d   +   ' ( ) '   :   c o m m a n d ;   
                                 i f   ( t h i s . c o n s o l e C o m m a n d s [ c o m m a n d ] . d e s c r i p t i o n )   {   
                                         m a x l e n   =   m a x l e n   >   _ c o m m a n d . l e n g t h   ?   m a x l e n   :   _ c o m m a n d . l e n g t h   
                                 }   
                         }   
                 }   
   
                 i f   ( ( t h i s . c o n s o l e C o m m a n d s . h e l p )   & &   ( t y p e o f   t h i s . c o n s o l e C o m m a n d s . h e l p   = = =   ' s t r i n g '   | |   t y p e o f   t h i s . c o n s o l e C o m m a n d s . h e l p   = = =   ' f u n c t i o n ' ) )   {   
                         r e s . p u s h ( t y p e o f   t h i s . c o n s o l e C o m m a n d s . h e l p   = = =   ' s t r i n g '   ?   t h i s . c o n s o l e C o m m a n d s . h e l p   :   t h i s . c o n s o l e C o m m a n d s . h e l p ( )   +   '   C o m m a n d s : ' ) ;   
                 }   
                 f o r   ( c o m m a n d   i n   t h i s . c o n s o l e C o m m a n d s )   {   
                         i f   ( c o m m a n d   ! = =   ' h e l p '   & &   t h i s . c o n s o l e C o m m a n d s [ c o m m a n d ] . c o m m a n d   & &   t h i s . c o n s o l e C o m m a n d s [ c o m m a n d ] . d e s c r i p t i o n )   {   
                                 l e t   _ c o m m a n d   =   t y p e o f   t h i s . c o n s o l e C o m m a n d s [ c o m m a n d ] . c o m m a n d   = = =   ' f u n c t i o n '   ?   c o m m a n d   +   ' ( ) '   :   c o m m a n d ;   
                                 r e s . p u s h ( _ c o m m a n d   +   '   ' . r e p e a t ( m a x l e n   -   _ c o m m a n d . l e n g t h )   +   
                                         ' \ t '   +   t h i s . c o n s o l e C o m m a n d s [ c o m m a n d ] . d e s c r i p t i o n   
                                 ) ;   
                         }   
                 }   
   
                 b i n d i n g s . h e l p   =   d b g . f i n d A l l G l o b a l s ( ) [ 0 ] . m a k e D e b u g g e e V a l u e ( ( )   = >   r e s . j o i n ( ' \ r \ n ' ) ) ;   
   
 / *   
                 / /   G e t   t h e   W e b   C o n s o l e   c o m m a n d s   f o r   t h e   g i v e n   d e b u g g e r   w i n d o w .   
                 l e t   h e l p e r s   =   t h i s . _ g e t W e b C o n s o l e C o m m a n d s ( d b g W i n d o w ) ;   
                 l e t   b i n d i n g s   =   h e l p e r s . s a n d b o x ; * /   
                 i f   ( b i n d S e l f )   {   
                         b i n d i n g s . _ s e l f   =   b i n d S e l f ;   
                 }   
   
                 i f   ( a O p t i o n s . s e l e c t e d N o d e A c t o r )   {   
                         t h r o w   n e w   E r r o r ( ' t o d o ' ) ; / *   
                         l e t   a c t o r   =   t h i s . c o n n . g e t A c t o r ( a O p t i o n s . s e l e c t e d N o d e A c t o r ) ;   
                         i f   ( a c t o r )   {   
                                 h e l p e r s . s e l e c t e d N o d e   =   a c t o r . r a w N o d e ;   
                         } * /   
                 }   
 / *   
                 / /   C h e c k   i f   t h e   D e b u g g e r . F r a m e   o r   D e b u g g e r . O b j e c t   f o r   t h e   g l o b a l   i n c l u d e   
                 / /   $   o r   $ $ .   W e   w i l l   n o t   o v e r w r i t e   t h e s e   f u n c t i o n s   w i t h   t h e   W e b   C o n s o l e   
                 / /   c o m m a n d s .   
                 l e t   f o u n d $   =   f a l s e ,   f o u n d $ $   =   f a l s e ;   
                 i f   ( f r a m e )   {   
                         l e t   e n v   =   f r a m e . e n v i r o n m e n t ;   
                         i f   ( e n v )   {   
                                 f o u n d $   =   ! ! e n v . f i n d ( " $ " ) ;   
                                 f o u n d $ $   =   ! ! e n v . f i n d ( " $ $ " ) ;   
                         }   
                 }   
                 e l s e   {   
                         f o u n d $   =   ! ! d b g W i n d o w . g e t O w n P r o p e r t y D e s c r i p t o r ( " $ " ) ;   
                         f o u n d $ $   =   ! ! d b g W i n d o w . g e t O w n P r o p e r t y D e s c r i p t o r ( " $ $ " ) ;   
                 }   
   
                 l e t   $   =   n u l l ,   $ $   =   n u l l ;   
                 i f   ( f o u n d $ )   {   
                         $   =   b i n d i n g s . $ ;   
                         d e l e t e   b i n d i n g s . $ ;   
                 }   
                 i f   ( f o u n d $ $ )   {   
                         $ $   =   b i n d i n g s . $ $ ;   
                         d e l e t e   b i n d i n g s . $ $ ;   
                 }   
   
                 / /   R e a d y   t o   e v a l u a t e   t h e   s t r i n g .   
                 h e l p e r s . e v a l I n p u t   =   a S t r i n g ;   
 * /   
                 l e t   e v a l O p t i o n s ;   
                 i f   ( t y p e o f   a O p t i o n s . u r l   = =   " s t r i n g " )   {   
                         e v a l O p t i o n s   =   {   u r l :   a O p t i o n s . u r l   } ;   
                 }   
   
                 l e t   r e s u l t ;   
                 i f   ( f r a m e )   {   
                         r e s u l t   =   f r a m e . e v a l W i t h B i n d i n g s ( a S t r i n g ,   b i n d i n g s ,   e v a l O p t i o n s ) ;   
                 }   
                 e l s e   {   
                         r e s u l t   =   d b g W i n d o w . e x e c u t e I n G l o b a l W i t h B i n d i n g s ( a S t r i n g ,   b i n d i n g s ,   e v a l O p t i o n s ) ;   
                 }   
   
 / *                 l e t   h e l p e r R e s u l t   =   h e l p e r s . h e l p e r R e s u l t ;   
                 d e l e t e   h e l p e r s . e v a l I n p u t ;   
                 d e l e t e   h e l p e r s . h e l p e r R e s u l t ;   
                 d e l e t e   h e l p e r s . s e l e c t e d N o d e ;   
   
                 i f   ( $ )   {   
                         b i n d i n g s . $   =   $ ;   
                 }   
                 i f   ( $ $ )   {   
                         b i n d i n g s . $ $   =   $ $ ;   
                 }   
   
                 i f   ( b i n d i n g s . _ s e l f )   {   
                         d e l e t e   b i n d i n g s . _ s e l f ;   
                 }   
 * /   
                 r e t u r n   {   
                         r e s u l t :   r e s u l t ,   
 / /                         h e l p e r R e s u l t :   h e l p e r R e s u l t ,   
                         d b g :   d b g ,   
                         f r a m e :   f r a m e   
 / /                         w i n d o w :   d b g W i n d o w   
                 } ;   
         }   
         a u t o c o m p l e t e ( a R e q u e s t )   
         {   
                 l e t   f r a m e A c t o r I d   =   a R e q u e s t . f r a m e A c t o r ;   
                 l e t   d b g O b j e c t   =   n u l l ;   
                 l e t   e n v i r o n m e n t   =   n u l l ;   
                 l e t   h a d D e b u g g e e   =   f a l s e ;   
   
                 / /   T h i s   i s   t h e   c a s e   o f   t h e   p a u s e d   d e b u g g e r   
                 i f   ( f r a m e A c t o r I d )   {   
                         l e t   f r a m e A c t o r   =   a c t o r M a n a g e r . g e t A c t o r ( f r a m e A c t o r I d ) ;   
                         i f   ( f r a m e A c t o r )   {   
                                 l e t   f r a m e   =   f r a m e A c t o r . _ f r a m e ;   
                                 e n v i r o n m e n t   =   f r a m e . e n v i r o n m e n t ;   
                         }   
                         e l s e   {   
                                 D e v T o o l s U t i l s . r e p o r t E x c e p t i o n ( " o n A u t o c o m p l e t e " ,   
                                         E r r o r ( " T h e   f r a m e   a c t o r   w a s   n o t   f o u n d :   "   +   f r a m e A c t o r I d ) ) ;   
                         }   
                 }   
                 / /   T h i s   i s   t h e   g e n e r a l   c a s e   ( n o n - p a u s e d   d e b u g g e r )   
                 e l s e   {   
 / *                         h a d D e b u g g e e   =   t h i s . d b g . h a s D e b u g g e e ( t h i s . e v a l W i n d o w ) ;   
                         d b g O b j e c t   =   t h i s . d b g . a d d D e b u g g e e ( t h i s . e v a l W i n d o w ) ; * /   
                         l e t   d b g   =   a c t o r M a n a g e r . t h r e a d . d b g ;   
                         d b g O b j e c t   =     d b g . m a k e G l o b a l O b j e c t R e f e r e n c e ( d b g _ b i n d i n g . g l o b a l ) ;   
                 }   
   
                 l e t   r e s u l t   =   J S P r o p e r t y P r o v i d e r ( d b g O b j e c t ,   e n v i r o n m e n t ,   a R e q u e s t . t e x t ,   
                                 a R e q u e s t . c u r s o r ,   f r a m e A c t o r I d )   | |   { } ;   
   
                 / / i f   ( ! h a d D e b u g g e e   & &   d b g O b j e c t )   {   
                 / /         t h i s . d b g . r e m o v e D e b u g g e e ( t h i s . e v a l W i n d o w ) ;   
                 / / }   
   
                 l e t   m a t c h e s   =   r e s u l t . m a t c h e s   | |   [ ] ;   
                 l e t   r e q T e x t   =   a R e q u e s t . t e x t . s u b s t r ( 0 ,   a R e q u e s t . c u r s o r ) ;   
   
                 / /   W e   c o n s i d e r   ' $ '   a s   a l p h a n u m e r c   b e c a u s e   i t   i s   u s e d   i n   t h e   n a m e s   o f   s o m e   
                 / /   h e l p e r   f u n c t i o n s .   
                 l e t   l a s t N o n A l p h a I s D o t   =   / [ . ] [ a - z A - Z 0 - 9 $ ] * $ / . t e s t ( r e q T e x t ) ;   
 / *                 i f   ( ! l a s t N o n A l p h a I s D o t )   {   
                         i f   ( ! t h i s . _ w e b C o n s o l e C o m m a n d s C a c h e )   {   
                                 l e t   h e l p e r s   =   {   
                                         s a n d b o x :   O b j e c t . c r e a t e ( n u l l )   
                                 } ;   
                                 a d d W e b C o n s o l e C o m m a n d s ( h e l p e r s ) ;   
                                 t h i s . _ w e b C o n s o l e C o m m a n d s C a c h e   =   
                                         O b j e c t . g e t O w n P r o p e r t y N a m e s ( h e l p e r s . s a n d b o x ) ;   
                         }   
                         m a t c h e s   =   m a t c h e s . c o n c a t ( t h i s . _ w e b C o n s o l e C o m m a n d s C a c h e   
                                 . f i l t e r ( n   = >   n . s t a r t s W i t h ( r e s u l t . m a t c h P r o p ) ) ) ;   
                 } * /   
   
                 r e t u r n   {   
 / /                         f r o m :   t h i s . a c t o r I D ,   
                         m a t c h e s :   m a t c h e s . s o r t ( ) ,   
                         m a t c h P r o p :   r e s u l t . m a t c h P r o p   
                 } ;   
         }   
         c l e a r M e s s a g e s C a c h e ( a R e q u e s t ) {   
                 r e t u r n   { }   
         }   
 }   
   
 c l a s s   T h r e a d A c t o r   e x t e n d s   A c t o r   {   
         c o n s t r u c t o r ( )   {   
                 s u p e r ( " t h r e a d " ) ;   
                 t h i s . d b g   =   n e w   D e b u g g e r ( d b g _ b i n d i n g . g l o b a l ) ;   
                 t h i s . d b g . e n a b l e d   =   f a l s e ;   
         }   
         a t t a c h ( a R e q u e s t )   {   
                 t h i s . d b g . e n a b l e d   =   t r u e ;   
                 t h i s . d b g . o n N e w S c r i p t   =   t h i s . _ o n N e w S c r i p t ;   
                 t h i s . d b g . o n D e b u g g e r S t a t e m e n t   =   t h i s . _ o n D e b u g g e r S t a t e m e n t ;   
                 t h i s . _ o p t i o n s   =   { } ;   
                 t h i s . _ p r e v P o s i t i o n   =   {   
                         f r a m e :   n u l l ,   
                         l i n e :   n u l l   
                 } ;   
   
                 r e t u r n   {   
                         " t y p e " :   " p a u s e d " ,   
                         " w h y " :   { " t y p e " :   " a t t a c h e d " }   
                 }   
         }   
         d e t a c h ( a R e q u e s t )   {   
                 t h i s . d b g . e n a b l e d   =   f a l s e ;   
                 d b g _ b i n d i n g . p a u s e d   =   f a l s e ;   
                 r e t u r n   {   
                         t y p e :   " d e t a c h e d "   
                 } ;   
         }   
         s o u r c e s ( a R e q u e s t )   {   
                 l e t   s o u r c e s   =   n e w   S o u r c e s A c t o r ( ) ,   
                         r e s   =   [ ] ;   
                 t h i s . d b g . f i n d S c r i p t s ( ) . f o r E a c h ( f u n c t i o n   ( s c r i p t )   {   
                         l e t   r e s p   =   s o u r c e s . _ a d d S o u r c e ( s c r i p t . s o u r c e ) ;   
                         i f   ( r e s p )   
                                 r e s . p u s h ( r e s p ) ;   
                 } ) ;   
                 r e t u r n   { " s o u r c e s " :   r e s } ;   
         }   
         f r a m e s ( a R e q u e s t )   {   
                 l e t   r e s p   =   [ ] ,   
                         f r a m e   =   a c t o r M a n a g e r . g e t A c t o r ( ' f r a m e ' ) ;   
                 w h i l e   ( f r a m e )   {   
                         r e s p . p u s h ( f r a m e . _ r e s p ) ;   
                         f r a m e   =   f r a m e . o l d e r ;   
                 }   
                 r e t u r n   {   
                         f r a m e s :   r e s p   
                 } ;   
         }   
         r e c o n f i g u r e ( a R e q u e s t )   {   
                 r e t u r n   { } ;   
         }   
         c l i e n t E v a l u a t e ( a R e q u e s t )   {   
                 i f   ( ! d b g _ b i n d i n g . p a u s e d )   {   
                         r e t u r n   {   e r r o r :   " w r o n g S t a t e " ,   
                                 m e s s a g e :   " D e b u g g e e   m u s t   b e   p a u s e d   t o   e v a l u a t e   c o d e . "   } ;   
                 }   
   
                 l e t   f r a m e   =   a c t o r M a n a g e r . g e t A c t o r ( a R e q u e s t . f r a m e ) . _ f r a m e ;   
                 i f   ( ! f r a m e )   {   
                         r e t u r n   {   e r r o r :   " u n k n o w n F r a m e " ,   
                                 m e s s a g e :   " E v a l u a t i o n   f r a m e   n o t   f o u n d "   } ;   
                 }   
   
                 i f   ( ! f r a m e . e n v i r o n m e n t )   {   
                         r e t u r n   {   e r r o r :   " n o t D e b u g g e e " ,   
                                 m e s s a g e :   " c a n n o t   a c c e s s   t h e   e n v i r o n m e n t   o f   t h i s   f r a m e . "   } ;   
                 }   
   
                 l e t   y o u n g e s t   =   a c t o r M a n a g e r . g e t A c t o r ( ' f r a m e ' ) ;   
   
                 / /   P u t   o u r s e l v e s   b a c k   i n   t h e   r u n n i n g   s t a t e   a n d   i n f o r m   t h e   c l i e n t .   
                 / / l e t   r e s u m e d a R e q u e s t   =   t h i s . _ r e s u m e d ( ) ;   
                 / / t h i s . c o n n . s e n d ( r e s u m e d a R e q u e s t ) ;   
                 d b g _ b i n d i n g . s e n d ( {   
                         f r o m :   t h i s . f u l l A c t o r ,   
                         t y p e :   " r e s u m e d "   
                 } ) ;   
   
                 / /   R u n   t h e   e x p r e s s i o n .   
                 / /   X X X :   t e s t   s y n t a x   e r r o r s   
                 l e t   c o m p l e t i o n   =   f r a m e . e v a l ( a R e q u e s t . e x p r e s s i o n ) ;   
   
                 / /   R e t u r n   b a c k   t o   o u r   p r e v i o u s   p a u s e ' s   e v e n t   l o o p .   
                 r e t u r n   t h i s . _ p a u s e d ( y o u n g e s t ,   { t y p e :   " c l i e n t E v a l u a t e d " ,   
                         f r a m e F i n i s h e d :   t h i s . c r e a t e P r o t o c o l C o m p l e t i o n V a l u e ( c o m p l e t i o n )   } ) ;   
         }   
         i n t e r r u p t ( a R e q u e s t )   {   
                 / * i f   ( t h i s . s t a t e   = =   " e x i t e d " )   {   
                         r e t u r n   {   t y p e :   " e x i t e d "   } ;   
                 }   e l s e   i f   ( t h i s . s t a t e   = =   " p a u s e d " )   { * /   
                 i f   ( d b g _ b i n d i n g . p a u s e d )   {   
                         / /   T O D O :   r e t u r n   t h e   a c t u a l   r e a s o n   f o r   t h e   e x i s t i n g   p a u s e .   
                         r e t u r n   {   t y p e :   " p a u s e d " ,   w h y :   {   t y p e :   " a l r e a d y P a u s e d "   }   } ;   
                 }   / * e l s e   i f   ( t h i s . s t a t e   ! =   " r u n n i n g " )   {   
                         r e t u r n   {   e r r o r :   " w r o n g S t a t e " ,   
                                 m e s s a g e :   " R e c e i v e d   i n t e r r u p t   r e q u e s t   i n   "   +   t h i s . s t a t e   +   
                                 "   s t a t e . "   } ;   
                 } * /   
   
                 t r y   {   
                         / /   I f   e x e c u t i o n   s h o u l d   p a u s e   j u s t   b e f o r e   t h e   n e x t   J a v a S c r i p t   b y t e c o d e   i s   
                         / /   e x e c u t e d ,   j u s t   s e t   a n   o n E n t e r F r a m e   h a n d l e r .   
                         i f   ( a R e q u e s t . w h e n   = =   " o n N e x t " )   {   
                                 l e t   y o u n g e s t   =   t h i s . d b g . g e t N e w e s t F r a m e ( ) ;   
                                 i f   ( y o u n g e s t )   {   
                                         y o u n g e s t . o n S t e p   =   f u n c t i o n ( )   {   
                                                 r e t u r n   a c t o r M a n a g e r . t h r e a d . _ p a u s e A n d R e s p o n d ( t h i s ,   { t y p e :   " i n t e r r u p t e d " ,   o n N e x t :   t r u e } ) ;   
                                         }   
                                 }   e l s e   {   
                                         l e t   o n E n t e r F r a m e   =   ( a F r a m e )   = >   {   
                                                 r e t u r n   t h i s . _ p a u s e A n d R e s p o n d ( a F r a m e ,   { t y p e :   " i n t e r r u p t e d " ,   o n N e x t :   t r u e } ) ;   
                                         } ;   
                                         t h i s . d b g . o n E n t e r F r a m e   =   o n E n t e r F r a m e ;   
                                 }   
                                 r e t u r n   {   t y p e :   " w i l l I n t e r r u p t "   } ;   
                         }   
   
                         / /   I f   e x e c u t i o n   s h o u l d   p a u s e   i m m e d i a t e l y ,   j u s t   p u t   o u r s e l v e s   i n   t h e   p a u s e d   
                         / /   s t a t e .   
                         / / l e t   r e s p   =   t h i s . _ p a u s e d ( u n d e f i n e d ,   {   t y p e :   " i n t e r r u p t e d "   } ) ;   
                         t h i s . _ p a u s e A n d R e s p o n d ( t h i s . d b g . g e t N e w e s t F r a m e ( ) ,   {   t y p e :   " i n t e r r u p t e d " } ) ;   
                         r e t u r n   { } ;   
                         / / i f   ( ! a R e q u e s t )   {   
                         / /         r e t u r n   {   e r r o r :   " n o t I n t e r r u p t e d "   } ;   
                         / / }   
                         / / a R e q u e s t . w h y   =   {   t y p e :   " i n t e r r u p t e d "   } ;   
   
                         / / / /   S e n d   t h e   r e s p o n s e   t o   t h e   i n t e r r u p t   r e q u e s t   n o w   ( r a t h e r   t h a n   
                         / / / /   r e t u r n i n g   i t ) ,   b e c a u s e   w e ' r e   g o i n g   t o   s t a r t   a   n e s t e d   e v e n t   l o o p   
                         / / / /   h e r e .   
                         / / t h i s . c o n n . s e n d ( a R e q u e s t ) ;   
                         / /   
                         / / / /   S t a r t   a   n e s t e d   e v e n t   l o o p .   
                         / / t h i s . _ p u s h T h r e a d P a u s e ( ) ;   
                         / /   
                         / / / /   W e   a l r e a d y   s e n t   a   r e s p o n s e   t o   t h i s   r e q u e s t ,   d o n ' t   s e n d   o n e   
                         / / / /   n o w .   
                         / / r e t u r n   n u l l ;   
                 }   c a t c h   ( e )   {   
                         D e v T o o l s U t i l s . r e p o r t E x c e p t i o n ( ' t h r e a d . i n t e r r u p t ' ,   e ) ;   
                         r e t u r n   {   e r r o r :   " n o t I n t e r r u p t e d " ,   m e s s a g e :   e . t o S t r i n g ( )   } ;   
                 }   
         }   
         r e s u m e ( a R e q u e s t )   {   
                 d b g _ b i n d i n g . p a u s e d   =   f a l s e ;   
                 i f   ( a R e q u e s t . r e s u m e L i m i t )   {   
                         t h i s . _ h a n d l e R e s u m e L i m i t ( a R e q u e s t ) ;   
                 }   e l s e   {   
                         t h i s . _ c l e a r S t e p p i n g H o o k s ( t h i s . d b g . g e t N e w e s t F r a m e ( ) ) ;   
                 }   
   
                 t h i s . _ o p t i o n s . p a u s e O n E x c e p t i o n s   =   a R e q u e s t . p a u s e O n E x c e p t i o n s ;   
                 t h i s . _ o p t i o n s . i g n o r e C a u g h t E x c e p t i o n s   =   a R e q u e s t . i g n o r e C a u g h t E x c e p t i o n s ;   
                 t h i s . _ m a y b e P a u s e O n E x c e p t i o n s ( ) ;   
   
                 r e t u r n   {   
                         " t y p e " :   " r e s u m e d "   
                 }   
         }   
         _ h a n d l e R e s u m e L i m i t ( a R e q u e s t )   {   
   
                 l e t   s t e p p i n g T y p e   =   a R e q u e s t . r e s u m e L i m i t . t y p e ;   
                 i f   ( [ " b r e a k " ,   " s t e p " ,   " n e x t " ,   " f i n i s h " ] . i n d e x O f ( s t e p p i n g T y p e )   = =   - 1 )   {   
                         r e t u r n   {   
                                 e r r o r :   " b a d P a r a m e t e r T y p e " ,   
                                 m e s s a g e :   " U n k n o w n   r e s u m e L i m i t   t y p e "   
                         } ;   
                 }   
   
                 / / c o n s t   g e n e r a t e d L o c a t i o n   =   a c t o r M a n a g e r . g e t A c t o r ( ' f r a m e ' ) . _ f r a m e ;   
                 / / r e t u r n   t h i s . s o u r c e s . g e t O r i g i n a l L o c a t i o n ( g e n e r a t e d L o c a t i o n )   
                 / /         . t h e n ( o r i g i n a l L o c a t i o n   = >   {   
                 / /                 c o n s t   {   o n E n t e r F r a m e ,   o n P o p ,   o n S t e p   }   =   t h i s . _ m a k e S t e p p i n g H o o k s ( o r i g i n a l L o c a t i o n ,   
                 / /                         s t e p p i n g T y p e ) ;   
   
                 / /   M a k e   s u r e   t h e r e   i s   s t i l l   a   f r a m e   o n   t h e   s t a c k   i f   w e   a r e   t o   c o n t i n u e   
                 / /   s t e p p i n g .   
                 l e t   s t e p F r a m e   =   a c t o r M a n a g e r . g e t A c t o r ( ' f r a m e ' ) . _ f r a m e ;   
                 i f   ( s t e p F r a m e . r e p o r t e d P o p )   {   
                         s t e p F r a m e   =   s t e p F r a m e . o l d e r ;   
                 }   
                 i f   ( ! s t e p F r a m e   | |   ! s t e p F r a m e . s c r i p t )   {   
                         s t e p F r a m e   =   s t e p F r a m e   =   n u l l ;   
                 }   
                 / / l e t   s t e p F r a m e   =   t h i s . _ g e t N e x t S t e p F r a m e ( t h i s . y o u n g e s t F r a m e ) ;   
                 i f   ( s t e p F r a m e )   {   
                         s w i t c h   ( s t e p p i n g T y p e )   {   
                                 c a s e   " s t e p " :   
                                         t h i s . d b g . o n E n t e r F r a m e   =   t h i s . _ o n E n t e r F r a m e ;   
                                 / /   F a l l   t h r o u g h .   
                                 c a s e   " b r e a k " :   
                                 c a s e   " n e x t " :   
                                         i f   ( s t e p p i n g T y p e   = = =   " b r e a k " )   {   
                                                 t h i s . _ p r e v P o s i t i o n   =   {   
                                                         f r a m e :   n u l l ,   
                                                         l i n e :   n u l l   
                                                 }   
                                         }   
                                         i f   ( s t e p F r a m e . s c r i p t )   {   
                                                 s t e p F r a m e . o n S t e p   =   t h i s . _ o n S t e p ;   
                                         }   
                                 / / s t e p F r a m e . o n P o p   =   o n P o p ;   
                                 / / b r e a k ;   
                                 c a s e   " f i n i s h " :   
                                         s t e p F r a m e . o n P o p   =   t h i s . _ o n P o p ;   
                         }   
                 }   
                 / /   
                 / /         r e t u r n   t r u e ;   
                 / / } ) ;   
   
         }   
         _ c l e a r S t e p p i n g H o o k s ( f r a m e ) {   
                 i f   ( f r a m e   & &   f r a m e . l i v e )   {   
                         w h i l e   ( f r a m e )   {   
                                 f r a m e . o n S t e p   =   u n d e f i n e d ;   
                                 f r a m e . o n P o p   =   u n d e f i n e d ;   
                                 f r a m e   =   f r a m e . o l d e r ;   
                         }   
                 }   
         }   
         _ m a y b e P a u s e O n E x c e p t i o n s ( )   {   
                 i f   ( t h i s . _ o p t i o n s . p a u s e O n E x c e p t i o n s )   {   
                         t h i s . d b g . o n E x c e p t i o n U n w i n d   =   t h i s . _ o n E x c e p t i o n U n w i n d . b i n d ( t h i s ) ;   
                 }   
         }   
         _ p a u s e d ( f r a m e A c t o r ,   w h y ) {   
                 l e t   f r a m e   =   f r a m e A c t o r   ?   f r a m e A c t o r . _ f r a m e   :   n u l l ;   
                 / /   C l e a r   s t e p p i n g   h o o k s .   
                 t h i s . d b g . o n E n t e r F r a m e   =   u n d e f i n e d ;   
                 t h i s . d b g . o n E x c e p t i o n U n w i n d   =   u n d e f i n e d ;   
                 i f   ( f r a m e )   {   
                         f r a m e . o n S t e p   =   u n d e f i n e d ;   
                         f r a m e . o n P o p   =   u n d e f i n e d ;   
                 }   
                 r e t u r n   {   
                         " t y p e " :   " p a u s e d " ,   
                         " f r a m e " :   f r a m e A c t o r   ?   f r a m e A c t o r . _ r e s p   :   u n d e f i n e d ,   
                         " p o p p e d F r a m e s " :   [ ] ,   
                         " w h y " :   w h y   
                 } ;   
         }   
         _ o n N e w S c r i p t ( s c r i p t ,   g l o b a l )   {   
                 l e t   r e s p   =   a c t o r M a n a g e r . s o u r c e . _ a d d S o u r c e ( s c r i p t . s o u r c e ) ;   
                 i f   ( r e s p ) {   
                         / / r e s p . f r o m   =   a c t o r M a n a g e r . t h r e a d . f u l l A c t o r ;   
                         d b g _ b i n d i n g . s e n d ( {   
                                 f r o m :   a c t o r M a n a g e r . t h r e a d . f u l l A c t o r ,   
                                 t y p e :   " n e w S o u r c e " ,   
                                 s o u r c e :   r e s p   
                         } ) ;   
                 }   
         }   
         _ o n D e b u g g e r S t a t e m e n t ( f r a m e )   {   
                 r e t u r n   a c t o r M a n a g e r . t h r e a d . _ p a u s e A n d R e s p o n d ( f r a m e ,   { " t y p e " :   " d e b u g g e r S t a t e m e n t " } ) ;   
         }   
         _ o n E n t e r F r a m e ( f r a m e )   {   
                 r e t u r n   a c t o r M a n a g e r . t h r e a d . _ p a u s e A n d R e s p o n d ( f r a m e ,   { " t y p e " :   " r e s u m e L i m i t " } ) ;   
         }   
         _ o n E x c e p t i o n U n w i n d ( a F r a m e ,   a V a l u e )   {   
                 l e t   w i l l B e C a u g h t   =   f a l s e ;   
                 f o r   ( l e t   f r a m e   =   a F r a m e ;   f r a m e   ! =   n u l l ;   f r a m e   =   f r a m e . o l d e r )   {   
                         i f   ( f r a m e . s c r i p t . i s I n C a t c h S c o p e ( f r a m e . o f f s e t ) )   {   
                                 w i l l B e C a u g h t   =   t r u e ;   
                                 b r e a k ;   
                         }   
                 }   
   
                 i f   ( w i l l B e C a u g h t   & &   t h i s . _ o p t i o n s . i g n o r e C a u g h t E x c e p t i o n s )   {   
                         r e t u r n   u n d e f i n e d ;   
                 }   
   
                 / / c o n s t   g e n e r a t e d L o c a t i o n   =   t h i s . s o u r c e s . g e t F r a m e L o c a t i o n ( a F r a m e ) ;   
                 / / c o n s t   {   s o u r c e A c t o r   }   =   t h i s . u n s a f e S y n c h r o n i z e ( t h i s . s o u r c e s . g e t O r i g i n a l L o c a t i o n (   
                 / /         g e n e r a t e d L o c a t i o n ) ) ;   
                 / / c o n s t   u r l   =   s o u r c e A c t o r   ?   s o u r c e A c t o r . u r l   :   n u l l ;   
                 / /   
                 / / i f   ( t h i s . s o u r c e s . i s B l a c k B o x e d ( u r l ) )   {   
                 / /         r e t u r n   u n d e f i n e d ;   
                 / / }   
   
                 / / t r y   {   
                 / /         l e t   a R e q u e s t   =   t h i s . _ p a u s e d ( a F r a m e ) ;   
                 / /         i f   ( ! a R e q u e s t )   {   
                 / /                 r e t u r n   u n d e f i n e d ;   
                 / /         }   
                 / /   
                 / /         a R e q u e s t . w h y   =   {   t y p e :   " e x c e p t i o n " ,   
                 / /                 e x c e p t i o n :   t h i s . g e t G r i p ( a V a l u e )   
                 / /         } ;   
                 / /         t h i s . c o n n . s e n d ( a R e q u e s t ) ;   
                 / /   
                 / /         t h i s . _ p u s h T h r e a d P a u s e ( ) ;   
                 / / }   c a t c h ( e )   {   
                 / /         r e p o r t E r r o r ( e ,   " G o t   a n   e x c e p t i o n   d u r i n g   T A _ o n E x c e p t i o n U n w i n d :   " ) ;   
                 / / }   
                 / /   
                 / / r e t u r n   u n d e f i n e d ;   
                 r e t u r n   t h i s . _ p a u s e A n d R e s p o n d ( a F r a m e ,   f u n c t i o n ( f r a m e A c t o r ) {   
                         r e t u r n   {   
                                 t y p e :   " e x c e p t i o n " ,   
                                 e x c e p t i o n :   f r a m e A c t o r . g e t G r i p ( a V a l u e )   
                         } ;   
                 } )   
         }   
         _ o n S t e p ( ) {   
                 r e t u r n   a c t o r M a n a g e r . t h r e a d . _ p a u s e A n d R e s p o n d ( t h i s ,   { " t y p e " :   " r e s u m e L i m i t " } ) ;   
         }   
         _ o n P o p ( a C o m p l e t i o n )   {   
                 t h i s . r e p o r t e d P o p   =   t r u e ;   
   
                 a c t o r M a n a g e r . t h r e a d . _ p r e v P o s i t i o n   =   {   
                         f r a m e :   n u l l ,   
                         l i n e :   n u l l   
                 } ;   
   
                 r e t u r n   a c t o r M a n a g e r . t h r e a d . _ p a u s e A n d R e s p o n d ( t h i s ,   f u n c t i o n ( f r a m e A c t o r ) {   
                         l e t   w h y   =   {   
                                 " t y p e " :   " r e s u m e L i m i t " ,   
                                 f r a m e F i n i s h e d :   { }   
                         } ;   
                         i f   ( ! a C o m p l e t i o n )   {   
                                 w h y . f r a m e F i n i s h e d . t e r m i n a t e d   =   t r u e ;   
                         }   e l s e   i f   ( a C o m p l e t i o n . h a s O w n P r o p e r t y ( " r e t u r n " ) )   {   
                                 w h y . f r a m e F i n i s h e d . r e t u r n   =   f r a m e A c t o r . g e t G r i p ( a C o m p l e t i o n . r e t u r n ) ;   
                         }   e l s e   i f   ( a C o m p l e t i o n . h a s O w n P r o p e r t y ( " y i e l d " ) )   {   
                                 w h y . f r a m e F i n i s h e d . r e t u r n   =   f r a m e A c t o r . g e t G r i p ( a C o m p l e t i o n . y i e l d ) ;   
                         }   e l s e   {   
                                 w h y . f r a m e F i n i s h e d . t h r o w   =   f r a m e A c t o r . g e t G r i p ( a C o m p l e t i o n . t h r o w ) ;   
                         }   
                         r e t u r n   w h y ;   
                 } ) ;   
         }   
         _ i s P r e v P o s i t i o n ( f r a m e )   {   
                 r e t u r n   ( t h i s . _ p r e v P o s i t i o n . f r a m e   ! = =   f r a m e   | |   
                         t h i s . _ p r e v P o s i t i o n . l i n e   ! = =   f r a m e . s c r i p t . g e t O f f s e t L o c a t i o n ( f r a m e . o f f s e t ) . l i n e N u m b e r ) ;   
         }   
         _ p a u s e A n d R e s p o n d ( f r a m e ,   w h y ) {   
                 i f   ( ! d b g _ b i n d i n g . l i s t e n )   
                         r e t u r n   u n d e f i n e d ;   
                 i f   ( f r a m e   & &   ! a c t o r M a n a g e r . t h r e a d . _ i s P r e v P o s i t i o n ( f r a m e ) )   
                         r e t u r n   u n d e f i n e d ;   
                 d b g _ b i n d i n g . p a u s e d   =   t r u e ;   
                 i f   ( f r a m e )   {   
                         a c t o r M a n a g e r . t h r e a d . _ p r e v P o s i t i o n   =   {   
                                 f r a m e :   f r a m e ,   
                                 l i n e :   f r a m e . s c r i p t . g e t O f f s e t L o c a t i o n ( f r a m e . o f f s e t ) . l i n e N u m b e r   
                         } ;   
                 }   
                 l e t   f r a m e A c t o r   =   f r a m e   ?   n e w   F r a m e A c t o r ( f r a m e ) :   n u l l ,   
                         m s g   =   a c t o r M a n a g e r . t h r e a d . _ p a u s e d ( f r a m e A c t o r ,   t y p e o f ( w h y ) = = = " f u n c t i o n "   ?   w h y ( f r a m e A c t o r )   :   w h y ) ;   
                 m s g . f r o m   =   t h i s . f u l l A c t o r ;   
                 d b g _ b i n d i n g . s e n d ( m s g ) ;   
                 d o   {   
                         m s g   =   d b g _ b i n d i n g . r e a d ( ) ;   
                         n e w M e s s a g e ( m s g ) ;   
                         w h i l e   ( m s g   =   d b g _ b i n d i n g . r e a d ( f a l s e ) )   {   
                                 n e w C o n s o l e M e s s a g e ( m s g ) ;   
                         }   
                 }   w h i l e   ( d b g _ b i n d i n g . p a u s e d ) ;   
                 r e t u r n   u n d e f i n e d ;   
         }   
 }   
   
 c l a s s   S o u r c e s A c t o r   e x t e n d s   A c t o r   {   
         c o n s t r u c t o r   ( )   {   
                 s u p e r ( ' s o u r c e ' ) ;   
                 t h i s . _ s o u r c e s M a p   =   n e w   M a p ( )   
                 t h i s . s c r i p t C o u n t e r I D   =   1   
         }   
         _ a d d S o u r c e ( s o u r c e )   {   
                 i f   ( t h i s . _ s o u r c e s M a p . g e t ( s o u r c e ) )   
                         r e t u r n   u n d e f i n e d ;   
                 e l s e   
                         r e t u r n   n e w   S o u r c e A c t o r ( t h i s . s c r i p t C o u n t e r I D + + ,   s o u r c e ,   t h i s ) . _ r e s p   
         }   
 }   
   
 c l a s s   S o u r c e A c t o r   e x t e n d s   A c t o r   {   
         c o n s t r u c t o r   ( a c t o r I D ,   s o u r c e ,   p a r e n t )   {   
                 s u p e r ( a c t o r I D ,   p a r e n t ) ;   
                 p a r e n t . _ s o u r c e s M a p . s e t ( s o u r c e ,   t h i s )   
                 t h i s . _ s o u r c e   =   s o u r c e ;   
                 t h i s . _ b r e a k p o i n t s   =   { } ;   
         }   
         s o u r c e ( )   {   
                 r e t u r n   {   
                         " c o n t e n t T y p e " :   " t e x t / j a v a s c r i p t " ,   
                         " s o u r c e " :   t h i s . g e t G r i p ( t h i s . _ s o u r c e . t e x t )   
                 }   
         }   
         s e t B r e a k p o i n t ( a R e q u e s t ) {   
                 l e t   {   l o c a t i o n :   {   l i n e ,   c o l u m n   } ,   c o n d i t i o n   }   =   a R e q u e s t ,   
                         b r e a k p o i n t A c t o r   =   t h i s . _ g e t O r C r e a t e B r e a k p o i n t A c t o r ( l i n e ,   c o n d i t i o n ) ;   
                 r e t u r n   b r e a k p o i n t A c t o r   ?   b r e a k p o i n t A c t o r . _ r e s p   :   { } ;   
         }   
         _ g e t O r C r e a t e B r e a k p o i n t A c t o r ( l i n e ,   c o n d i t i o n ) {   
                 l e t   s c r i p t s   =   a c t o r M a n a g e r . t h r e a d . d b g . f i n d S c r i p t s ( { s o u r c e :   t h i s . _ s o u r c e ,   l i n e :   l i n e } ) ,   
                         e n t r y P o i n t s ;   
   
                 d o   {   
                         e n t r y P o i n t s   =   [ ] ;   
                         f o r   ( l e t   s c r i p t   o f   s c r i p t s )   {   
                                 l e t   o f f s e t s   =   s c r i p t . g e t L i n e O f f s e t s ( l i n e ) ;   
                                 i f   ( o f f s e t s . l e n g t h   >   0 )   
                                         e n t r y P o i n t s . p u s h ( {   
                                                 s c r i p t :   s c r i p t ,   
                                                 o f f s e t s :   o f f s e t s   
                                         } ) ;   
                         }   
                         / / e x i t   c o n d i t i o n s   
                         / / 1   -   f i n d   e n t r y P o i n t s   
                         / /   o r   
                         / / 2   -   n o t   f i n d   s c r i p t s   f o r   l i n e   
                         i f   ( e n t r y P o i n t s . l e n g t h   = =   0 )   
                                 s c r i p t s   =   a c t o r M a n a g e r . t h r e a d . d b g . f i n d S c r i p t s ( { s o u r c e :   t h i s . _ s o u r c e ,   l i n e :   + + l i n e } ) ;   
                 }   w h i l e (   e n t r y P o i n t s . l e n g t h   = =   0   & &   s c r i p t s . l e n g t h   ! =   0 ) ;   
                 i f   ( e n t r y P o i n t s . l e n g t h   >   0 )   {   
                         l e t   a c t o r   =   t h i s [ l i n e ]   ?   t h i s [ l i n e ]   :   n e w   B r e a k p o i n t A c t o r ( t h i s ,   l i n e ,   e n t r y P o i n t s ) ;   
                         a c t o r . _ c o n d i t i o n   =   c o n d i t i o n ;   
                         r e t u r n   a c t o r ;   
                 }   e l s e   {   
                         r e t u r n   n u l l ;   
                 }   
         }   
         g e t P r o p e r P a t h ( p )   {   
                 l e t   r e s   =   p ;   
                 / /   r e p l a c e   s i n g l e   b a c k s l a s h   w i t h   u r l   s l a s h   ( e v e r y   o c c u r r e n c e )   
                 r e s   =   r e s . r e p l a c e ( / \ \ / g ,   ' / ' ) ;   
                 i f   ( r e s . s t a r t s W i t h ( ' / / ' ) )   {   
                         r e s   =   ' f i l e : '   +   r e s   
                 }   
                 e l s e   i f   ( r e s . c h a r A t ( 1 )   = =   ' : ' )   {   
                         r e s   =   ' f i l e : / / / '   +   r e s   
                 }     
                 r e t u r n   r e s ;   
         }   
         f i n d S o u r c e M a p D a t a ( d a t a )   {   
                 l e t   r e s u l t   =   u n d e f i n e d ;   
                 l e t   s e a r c h R e s u l t   =   n e w   R e g E x p ( ' \ / \ / #   ? s o u r c e M a p p i n g U R L   ? =   ? ( . * ) ' ,   ' i ' ) . e x e c ( d a t a ) ;   
                 i f   ( s e a r c h R e s u l t )   {   
                         r e s u l t   =   s e a r c h R e s u l t . p o p ( ) ;   
                 }   
                 r e t u r n   r e s u l t ;   
         }   
         g e t   _ r e s p ( ) {   
                 l e t   s o u r c e   =   t h i s . _ s o u r c e ; / /   | |   t h i s . g e n e r a t e d S o u r c e ;   
                 / /   T h i s   m i g h t   n o t   h a v e   a   s o u r c e   o r   a   g e n e r a t e d S o u r c e   b e c a u s e   w e   
                 / /   t r e a t   H T M L   p a g e s   w i t h   i n l i n e   s c r i p t s   a s   a   s p e c i a l   S o u r c e A c t o r   
                 / /   t h a t   d o e s n ' t   h a v e   e i t h e r   
                 l e t   i n t r o d u c t i o n U r l   =   n u l l ;   
                 i f   ( s o u r c e   & &   s o u r c e . i n t r o d u c t i o n S c r i p t )   {   
                         i n t r o d u c t i o n U r l   =   s o u r c e . i n t r o d u c t i o n S c r i p t . s o u r c e . u r l ;   
                 }   
                 l e t   a d d o n P a t h   =   u n d e f i n e d ;   
                 l e t   u r l   =   t h i s . _ s o u r c e . u r l ;   
                 i f   ( ! u r l   | |   u r l   = = =   ' d e b u g g e r   e v a l   c o d e ' )   {   
                         u r l   =   u n d e f i n e d ;   
                 }   e l s e   {   
                         u r l   =   t h i s . g e t P r o p e r P a t h ( u r l . s p l i t ( "   - >   " ) . p o p ( ) ) ;   
                         i f   ( u r l . s t a r t s W i t h ( ' f i l e : ' ) )   {   
                                 l e t   w e b A p p R o o t P a t h   =   t h i s . g e t P r o p e r P a t h ( d b g _ b i n d i n g . w e b A p p R o o t P a t h ) ;   
                                 i f   ( u r l . s t a r t s W i t h ( w e b A p p R o o t P a t h ) )   {   
                                         a d d o n P a t h   =   u r l . s u b s t r ( w e b A p p R o o t P a t h . l e n g t h ) ;   
                                 }   
                         }   
                 }   
                 r e t u r n   {   
                         " a c t o r " :   t h i s . f u l l A c t o r ,   
                         " u r l " :   u r l ,   
                         " a d d o n P a t h "   :   a d d o n P a t h ,   
                         " a d d o n I D " :   a d d o n P a t h   ?   d b g _ b i n d i n g . a d d o n I D   :   u n d e f i n e d ,   
                         " i s B l a c k B o x e d " :   f a l s e ,   
                         " i s P r e t t y P r i n t e d " :   f a l s e ,   
                         " i n t r o d u c t i o n U r l " :   i n t r o d u c t i o n U r l   ?   i n t r o d u c t i o n U r l . s p l i t ( '   - >   ' ) . p o p ( )   :   u n d e f i n e d ,   
                         i n t r o d u c t i o n T y p e :   s o u r c e   ?   s o u r c e . i n t r o d u c t i o n T y p e   :   ' ' ,   
                         " s o u r c e M a p U R L " :   t h i s . f i n d S o u r c e M a p D a t a ( s o u r c e . t e x t )   
                 }   
         }   
 }   
   
 c l a s s   B r e a k p o i n t A c t o r   e x t e n d s   A c t o r {   
         c o n s t r u c t o r   ( s o u r c e A c t o r ,   l i n e N o ,   e n t r y P o i n t s )   {   
                 s u p e r ( l i n e N o ,   s o u r c e A c t o r ) ;   
                 t h i s . _ l i n e N o   =   l i n e N o ;   
                 t h i s . _ s o u r c e A c t o r   =   s o u r c e A c t o r ;   
                 t h i s . _ s c r i p t s   =   [ ] ;   
                 f o r   ( l e t   { s c r i p t ,   o f f s e t s }   o f   e n t r y P o i n t s )   {   
                         f o r   ( l e t   o f f s e t   o f   o f f s e t s )   {   
                                 s c r i p t . s e t B r e a k p o i n t ( o f f s e t ,   t h i s ) ;   
                                 t h i s . _ s c r i p t s . p u s h ( s c r i p t ) ;   
                         }   
                 }   
         }   
         d e l e t e ( a R e q u e s t )   {   
                 f o r   ( l e t   s c r i p t   o f   t h i s . _ s c r i p t s )   {   
                         s c r i p t . c l e a r B r e a k p o i n t ( t h i s ) ;   
                 }   
                 d e l e t e   t h i s . _ s o u r c e A c t o r [ t h i s . _ a c t o r ] ;   
                 r e t u r n   { } ;   
         }   
         c h e c k C o n d i t i o n ( f r a m e )   {   
                 l e t   c o m p l e t i o n   =   f r a m e . e v a l ( t h i s . _ c o n d i t i o n ) ;   
                 i f   ( c o m p l e t i o n )   {   
                         i f   ( c o m p l e t i o n . t h r o w )   {   
                                 / /   T h e   e v a l u a t i o n   f a i l e d   a n d   t h r e w   
                                 l e t   m e s s a g e   =   " U n k n o w n   e x c e p t i o n " ;   
                                 t r y   {   
                                         i f   ( c o m p l e t i o n . t h r o w . g e t O w n P r o p e r t y D e s c r i p t o r )   {   
                                                 m e s s a g e   =   c o m p l e t i o n . t h r o w . g e t O w n P r o p e r t y D e s c r i p t o r ( " m e s s a g e " ) . v a l u e ;   
                                         }   e l s e   i f   ( c o m p l e t i o n . t o S t r i n g )   {   
                                                 m e s s a g e   =   c o m p l e t i o n . t o S t r i n g ( ) ;   
                                         }   
                                 }   c a t c h   ( e x )   { }   
                                 r e t u r n   {   
                                         r e s u l t :   t r u e ,   
                                         m e s s a g e :   m e s s a g e   
                                 } ;   
                         }   e l s e   i f   ( c o m p l e t i o n . y i e l d )   {   
                                 r e t u r n   {   r e s u l t :   u n d e f i n e d   } ;   
                                 / / a s s e r t ( f a l s e ,   " S h o u l d n ' t   e v e r   g e t   y i e l d   c o m p l e t i o n s   f r o m   a n   e v a l " ) ;   
                         }   e l s e   {   
                                 r e t u r n   {   r e s u l t :   c o m p l e t i o n . r e t u r n   ?   t r u e   :   f a l s e   } ;   
                         }   
                 }   e l s e   {   
                         / /   T h e   e v a l u a t i o n   w a s   k i l l e d   ( p o s s i b l y   b y   t h e   s l o w   s c r i p t   d i a l o g )   
                         r e t u r n   {   r e s u l t :   u n d e f i n e d   } ;   
                 }   
         }   
         h i t ( f r a m e )   {   
                 i f   ( f r a m e . o n S t e p )   {   
                         r e t u r n   u n d e f i n e d   
                 }   
                 l e t   r e a s o n   =   { } ;   
                 i f   ( ! t h i s . _ c o n d i t i o n )   {   
                         r e a s o n . t y p e   =   " b r e a k p o i n t " ;   
                         / /   T O D O :   a d d   t h e   r e s t   o f   t h e   b r e a k p o i n t s   o n   t h a t   l i n e   ( b u g   6 7 6 6 0 2 ) .   
                         r e a s o n . a c t o r s   =   [   t h i s . f u l l A c t o r   ] ;   
                 }   e l s e   {   
                         l e t   {   r e s u l t ,   m e s s a g e   }   =   t h i s . c h e c k C o n d i t i o n ( f r a m e ) ;   
                         i f   ( r e s u l t )   {   
                                 i f   ( ! m e s s a g e )   {   
                                         r e a s o n . t y p e   =   " b r e a k p o i n t " ;   
                                 }   e l s e   {   
                                         r e a s o n . t y p e   =   " b r e a k p o i n t C o n d i t i o n T h r o w n " ;   
                                         r e a s o n . m e s s a g e   =   m e s s a g e ;   
                                 }   
                                 r e a s o n . a c t o r s   =   [   t h i s . f u l l A c t o r   ] ;   
                         }   e l s e   {   
                                 r e t u r n   u n d e f i n e d ;   
                         }   
                 }   
                 r e t u r n   a c t o r M a n a g e r . t h r e a d . _ p a u s e A n d R e s p o n d ( f r a m e ,   r e a s o n ) ;   
         }   
         g e t   _ r e s p ( )   {   
                 r e t u r n   {   
                         a c t o r :   t h i s . f u l l A c t o r ,   
                         a c t u a l L o c a t i o n :   {   
                                 l i n e :   t h i s . _ l i n e N o ,   
                                 s o u r c e :   {   
                                         a c t o r :   t h i s . _ s o u r c e A c t o r . f u l l A c t o r   
                                 }   
                         } ,   
                         i s P e n d i n g :   f a l s e   
                 } ;   
         }   
 }   
   
 c l a s s   L S t r A c t o r   e x t e n d s   A c t o r   {   
         c o n s t r u c t o r   ( s t r ,   p a r e n t )   {   
                 s u p e r ( ' _ g r i p ' +   p a r e n t . _ g r i p s + + ,   p a r e n t ) ;   
                 t h i s . _ s t r   =   s t r ;   
         }   
         s u b s t r i n g ( a R e q u e s t )   {   
                 r e t u r n   {   
                         " s u b s t r i n g " :   t h i s . _ s t r . s u b s t r ( a R e q u e s t . s t a r t ,   a R e q u e s t . e n d )   
                 }   
         }   
         r e l e a s e ( a R e q u e s t )   {   
                 d e l e t e   t h i s . _ p a r e n t [ t h i s . _ a c t o r ] ;   
                 r e t u r n   { }   
         }   
         g e t   _ r e s p ( ) {   
                 r e t u r n   {   
                         " t y p e " :   " l o n g S t r i n g " ,   
                         " i n i t i a l " :   t h i s . _ s t r . s u b s t r ( 0 ,   L O N G _ S T R I N G _ I N I T I A L _ L E N G T H ) ,   
                         " l e n g t h " :   t h i s . _ s t r . l e n g t h ,   
                         " a c t o r " :   t h i s . f u l l A c t o r   
                 }   
         }   
   
 }   
   
 c l a s s   O b j e c t A c t o r   e x t e n d s   A c t o r   {   
         c o n s t r u c t o r ( o b j ,   p a r e n t )   {   
                 s u p e r ( ' _ g r i p ' +   p a r e n t . _ g r i p s + + ,   p a r e n t ) ;   
                 t h i s . _ o b j   =   o b j ;   
         }   
         g e t   _ r e s p ( ) {   
                 t h i s . _ p a r e n t . _ g r i p D e p t h + + ;   
                 l e t   r e s p   =   {   
                         " t y p e " :   " o b j e c t " ,   
                         " c l a s s " :   t h i s . _ o b j . c l a s s ,   
                         " a c t o r " :   t h i s . f u l l A c t o r ,   
                         " e x t e n s i b l e " :   t h i s . _ o b j . i s E x t e n s i b l e ( ) ,   
                         " f r o z e n " :   t h i s . _ o b j . i s F r o z e n ( ) ,   
                         " s e a l e d " :   t h i s . _ o b j . i s S e a l e d ( )   
                 } ;   
   
                 t r y   {   
                         / /   B u g   1 1 6 3 5 2 0 :   A s s e r t   o n   i n t e r n a l   f u n c t i o n s   
                         i f   ( t h i s . _ o b j . c l a s s   ! =   " F u n c t i o n " )   {   
                                 r e s p . o w n P r o p e r t y L e n g t h   =   t h i s . _ o b j . g e t O w n P r o p e r t y N a m e s ( ) . l e n g t h ;   
   
                         }   
                 }   c a t c h ( e )   { }   
   
                 l e t   p r e v i e w e r s   =   O b j e c t A c t o r P r e v i e w e r s [ t h i s . _ o b j . c l a s s ]   | |   O b j e c t A c t o r P r e v i e w e r s . O b j e c t   | |   [ ] ;   
   
                 f o r   ( l e t   f n   o f   p r e v i e w e r s )   {   
                         t r y   {   
                                 i f   ( f n ( t h i s ,   r e s p ) )   {   
                                         b r e a k ;   
                                 }   
                         }   c a t c h   ( e )   {   
                                 / / l e t   m s g   =   " O b j e c t A c t o r . p r o t o t y p e . g r i p   p r e v i e w e r   f u n c t i o n " ;   
                                 / / D e v T o o l s U t i l s . r e p o r t E x c e p t i o n ( m s g ,   e ) ;   
                         }   
                 }   
                 t h i s . _ p a r e n t . _ g r i p D e p t h - - ;   
                 r e t u r n   r e s p ;   
         }   
         p r o t o t y p e A n d P r o p e r t i e s ( a R e q u e s t )   {   
                 l e t   o w n P r o p e r t i e s   =   { } , / / O b j e c t . c r e a t e ( n u l l ) ,   
                         n a m e s ;   
   
                 t r y   {   
                         n a m e s   =   t h i s . _ o b j . g e t O w n P r o p e r t y N a m e s ( ) ;   
                 }   c a t c h   ( e x )   {   
                         / /   T h e   a b o v e   c a n   t h r o w   i f   t h i s . o b j   p o i n t s   t o   a   d e a d   o b j e c t .   
                         / /   T O D O :   w e   s h o u l d   u s e   C u . i s D e a d W r a p p e r ( )   -   s e e   b u g   8 8 5 8 0 0 .   
                         r e t u r n   {   
                                 p r o t o t y p e :   t h i s . g e t G r i p ( n u l l ) ,   
                                 o w n P r o p e r t i e s :   o w n P r o p e r t i e s ,   
                                 s a f e G e t t e r V a l u e s :   { } / / O b j e c t . c r e a t e ( n u l l )   
                         } ;   
                 }   
   
                 f o r   ( l e t   n a m e   o f   n a m e s )   {   
                         o w n P r o p e r t i e s [ n a m e ]   =   t h i s . _ p r o p e r t y D e s c r i p t o r ( n a m e ) ;   
                 }   
   
                 r e t u r n   {   
                         p r o t o t y p e :   t h i s . g e t G r i p ( t h i s . _ o b j . p r o t o ) ,   
                         o w n P r o p e r t i e s :   o w n P r o p e r t i e s ,   
                         s a f e G e t t e r V a l u e s :   t h i s . _ f i n d S a f e G e t t e r V a l u e s ( n a m e s )   
                 } ;   
         }   
         e n u m P r o p e r t i e s ( a R e q u e s t )   {   
                 l e t   a c t o r   =   n e w   P r o p e r t y I t e r a t o r A c t o r ( t h i s ,   a R e q u e s t . o p t i o n s ) ;   
                 / / t h i s . r e g i s t e r e d P o o l . a d d A c t o r ( a c t o r ) ;   
                 / / t h i s . i t e r a t o r s . a d d ( a c t o r ) ;   
                 r e t u r n   {   i t e r a t o r :   a c t o r . _ r e s p ( )   } ;   
         }   
         s c o p e ( a R e q u e s t )   {   
                 i f   ( t h i s . _ o b j . c l a s s   ! = =   " F u n c t i o n " )   {   
                         r e t u r n   {   
                                 e r r o r :   " o b j e c t N o t F u n c t i o n " ,   
                                 m e s s a g e :   " s c o p e   r e q u e s t   i s   o n l y   v a l i d   f o r   o b j e c t   g r i p s   w i t h   a "   +   
                                 "   ' F u n c t i o n '   c l a s s . "   
                         } ;   
                 }   
                 l e t   e n v ;   
                 i f   ( ! t h i s . _ o b j . e n v i r o n m e n t   | |   ! ( e n v   =   ( n e w   E n v i r o n m e n t A c t o r ( t h i s . _ o b j . e n v i r o n m e n t ,   t h i s ) ) . _ r e s p ) )   {   
                         r e t u r n   {   
                                 e r r o r :   " n o t D e b u g g e e " ,   
                                 m e s s a g e :   " c a n n o t   a c c e s s   t h e   e n v i r o n m e n t   o f   t h i s   f u n c t i o n . "   
                         } ;   
                 }   
                 r e t u r n   { s c o p e :   e n v } ;   
         }   
         r e l e a s e ( a R e q u e s t )   {   
                 d e l e t e   t h i s . _ p a r e n t [ t h i s . _ a c t o r ] ;   
                 r e t u r n   { }   
         }   
         d i s p l a y S t r i n g ( a R e q u e s t )   {   
                 c o n s t   s t r i n g   =   s t r i n g i f y ( t h i s . _ o b j ) ;   
                 r e t u r n   {   d i s p l a y S t r i n g :   t h i s . g e t G r i p ( s t r i n g )   } ;   
         }   
         g e t G r i p ( v a l u e ) {   
                 r e t u r n   t h i s . _ p a r e n t . g e t G r i p ( v a l u e ) ;   
         }   
         g e t G r i p D e p t h ( )   {   
                 r e t u r n   t h i s . _ p a r e n t . _ g r i p D e p t h ;   
         }   
         _ p r o p e r t y D e s c r i p t o r ( n a m e ,   o n l y E n u m e r a b l e )   {   
                 l e t   d e s c ;   
                 t r y   {   
                         d e s c   =   t h i s . _ o b j . g e t O w n P r o p e r t y D e s c r i p t o r ( n a m e ) ;   
                 }   c a t c h   ( e )   {   
                         / /   C a l l i n g   g e t O w n P r o p e r t y D e s c r i p t o r   o n   w r a p p e d   n a t i v e   p r o t o t y p e s   i s   n o t   
                         / /   a l l o w e d   ( b u g   5 6 0 0 7 2 ) .   I n f o r m   t h e   u s e r   w i t h   a   b o g u s ,   b u t   h o p e f u l l y   
                         / /   e x p l a n a t o r y ,   d e s c r i p t o r .   
                         r e t u r n   {   
                                 c o n f i g u r a b l e :   f a l s e ,   
                                 w r i t a b l e :   f a l s e ,   
                                 e n u m e r a b l e :   f a l s e ,   
                                 v a l u e :   e . n a m e   
                         } ;   
                 }   
   
                 i f   ( ! d e s c   | |   o n l y E n u m e r a b l e   & &   ! d e s c . e n u m e r a b l e )   {   
                         r e t u r n   u n d e f i n e d ;   
                 }   
   
                 l e t   r e t v a l   =   {   
                         c o n f i g u r a b l e :   d e s c . c o n f i g u r a b l e ,   
                         e n u m e r a b l e :   d e s c . e n u m e r a b l e   
                 } ;   
   
                 i f   ( " v a l u e "   i n   d e s c )   {   
                         r e t v a l . w r i t a b l e   =   d e s c . w r i t a b l e ;   
                         r e t v a l . v a l u e   =   t h i s . _ p a r e n t . g e t G r i p ( d e s c . v a l u e ) ;   
                 }   e l s e   {   
                         i f   ( " g e t "   i n   d e s c )   {   
                                 r e t v a l . g e t   =   t h i s . _ p a r e n t . g e t G r i p ( d e s c . g e t ) ;   
                         }   
                         i f   ( " s e t "   i n   d e s c )   {   
                                 r e t v a l . s e t   =   t h i s . _ p a r e n t . g e t G r i p ( d e s c . s e t ) ;   
                         }   
                 }   
                 r e t u r n   r e t v a l ;   
         }   
         _ f i n d S a f e G e t t e r V a l u e s ( o w n P r o p e r t i e s ,   l i m i t   =   0 )   {   
                 l e t   s a f e G e t t e r V a l u e s   =   { }   / / O b j e c t . c r e a t e ( n u l l ) ;   
                 l e t   o b j   =   t h i s . _ o b j ;   
                 l e t   l e v e l   =   0 ,   i   =   0 ;   
   
                 w h i l e   ( o b j )   {   
                         l e t   g e t t e r s   =   t h i s . _ f i n d S a f e G e t t e r s ( o b j ) ;   
                         f o r   ( l e t   n a m e   o f   g e t t e r s )   {   
                                 / /   A v o i d   o v e r w r i t i n g   p r o p e r t i e s   f r o m   p r o t o t y p e s   c l o s e r   t o   t h i s . o b j .   A l s o   
                                 / /   a v o i d   p r o v i d i n g   s a f e G e t t e r V a l u e s   f r o m   p r o t o t y p e s   i f   p r o p e r t y   | n a m e |   
                                 / /   i s   a l r e a d y   d e f i n e d   a s   a n   o w n   p r o p e r t y .   
                                 i f   ( n a m e   i n   s a f e G e t t e r V a l u e s   | |   
                                         ( o b j   ! =   t h i s . _ o b j   & &   o w n P r o p e r t i e s . i n d e x O f ( n a m e )   ! = =   - 1 ) )   {   
                                         c o n t i n u e ;   
                                 }   
   
                                 / /   I g n o r e   _ _ p r o t o _ _   o n   O b j e c t . p r o t o t y e .   
                                 i f   ( ! o b j . p r o t o   & &   n a m e   = =   " _ _ p r o t o _ _ " )   {   
                                         c o n t i n u e ;   
                                 }   
   
                                 l e t   d e s c   =   n u l l ,   g e t t e r   =   n u l l ;   
                                 t r y   {   
                                         d e s c   =   o b j . g e t O w n P r o p e r t y D e s c r i p t o r ( n a m e ) ;   
                                         g e t t e r   =   d e s c . g e t ;   
                                 }   c a t c h   ( e x )   {   
                                         / /   T h e   a b o v e   c a n   t h r o w   i f   t h e   c a c h e   b e c o m e s   s t a l e .   
                                 }   
                                 i f   ( ! g e t t e r )   {   
                                         o b j . _ s a f e G e t t e r s   =   n u l l ;   
                                         c o n t i n u e ;   
                                 }   
   
                                 l e t   r e s u l t   =   g e t t e r . c a l l ( t h i s . _ o b j ) ;   
                                 i f   ( r e s u l t   & &   ! ( " t h r o w "   i n   r e s u l t ) )   {   
                                         l e t   g e t t e r V a l u e   =   u n d e f i n e d ;   
                                         i f   ( " r e t u r n "   i n   r e s u l t )   {   
                                                 g e t t e r V a l u e   =   r e s u l t . r e t u r n ;   
                                         }   e l s e   i f   ( " y i e l d "   i n   r e s u l t )   {   
                                                 g e t t e r V a l u e   =   r e s u l t . y i e l d ;   
                                         }   
                                         / /   W e b I D L   a t t r i b u t e s   s p e c i f i e d   w i t h   t h e   L e n i e n t T h i s   e x t e n d e d   a t t r i b u t e   
                                         / /   r e t u r n   u n d e f i n e d   a n d   s h o u l d   b e   i g n o r e d .   
                                         i f   ( g e t t e r V a l u e   ! = =   u n d e f i n e d )   {   
                                                 s a f e G e t t e r V a l u e s [ n a m e ]   =   {   
                                                         g e t t e r V a l u e :   t h i s . _ p a r e n t . g e t G r i p ( g e t t e r V a l u e ) ,   
                                                         g e t t e r P r o t o t y p e L e v e l :   l e v e l ,   
                                                         e n u m e r a b l e :   d e s c . e n u m e r a b l e ,   
                                                         w r i t a b l e :   l e v e l   = =   0   ?   d e s c . w r i t a b l e   :   t r u e   
                                                 } ;   
                                                 i f   ( l i m i t   & &   + + i   = =   l i m i t )   {   
                                                         b r e a k ;   
                                                 }   
                                         }   
                                 }   
                         }   
                         i f   ( l i m i t   & &   i   = =   l i m i t )   {   
                                 b r e a k ;   
                         }   
                         o b j   =   o b j . p r o t o ;   
                         l e v e l + + ;   
                 }   
                 r e t u r n   s a f e G e t t e r V a l u e s ;   
         }   
         _ f i n d S a f e G e t t e r s ( o b j e c t )   {   
                 i f   ( o b j e c t . _ s a f e G e t t e r s )   {   
                         r e t u r n   o b j e c t . _ s a f e G e t t e r s ;   
                 }   
   
                 l e t   g e t t e r s   =   n e w   S e t ( ) ;   
                 l e t   n a m e s   =   [ ] ;   
                 t r y   {   
                         n a m e s   =   o b j e c t . g e t O w n P r o p e r t y N a m e s ( )   
                 }   c a t c h   ( e x )   {   
                         / /   C a l l i n g   g e t O w n P r o p e r t y N a m e s ( )   o n   s o m e   w r a p p e d   n a t i v e   p r o t o t y p e s   i s   n o t   
                         / /   a l l o w e d :   " c a n n o t   m o d i f y   p r o p e r t i e s   o f   a   W r a p p e d N a t i v e " .   S e e   b u g   9 5 2 0 9 3 .   
                 }   
   
                 f o r   ( l e t   n a m e   o f   n a m e s )   {   
                         l e t   d e s c   =   n u l l ;   
                         t r y   {   
                                 d e s c   =   o b j e c t . g e t O w n P r o p e r t y D e s c r i p t o r ( n a m e ) ;   
                         }   c a t c h   ( e )   {   
                                 / /   C a l l i n g   g e t O w n P r o p e r t y D e s c r i p t o r   o n   w r a p p e d   n a t i v e   p r o t o t y p e s   i s   n o t   
                                 / /   a l l o w e d   ( b u g   5 6 0 0 7 2 ) .   
                         }   
                         i f   ( ! d e s c   | |   d e s c . v a l u e   ! = =   u n d e f i n e d   | |   ! ( " g e t "   i n   d e s c ) )   {   
                                 c o n t i n u e ;   
                         }   
   
                         i f   ( D e v T o o l s U t i l s . h a s S a f e G e t t e r ( d e s c ) )   {   
                                 g e t t e r s . a d d ( n a m e ) ;   
                         }   
                 }   
   
                 o b j e c t . _ s a f e G e t t e r s   =   g e t t e r s ;   
                 r e t u r n   g e t t e r s ;   
         }   
 }   
   
 c l a s s   P r o p e r t y I t e r a t o r A c t o r   e x t e n d s   A c t o r   {   
         c o n s t r u c t o r ( o b j e c t A c t o r ,   o p t i o n s )   {   
                 s u p e r ( ' p r o p e r t y I t e r a t o r ' ,   o b j e c t A c t o r ) ;   
                 t h i s . o b j e c t A c t o r   =   o b j e c t A c t o r ;   
                 l e t   o w n P r o p e r t i e s   =   { } ,   
                         n a m e s   =   [ ] ,   
                         s a f e G e t t e r V a l u e s   =   { } ,   
                         s a f e G e t t e r N a m e s   =   [ ] ;   
                 t r y   {   
                         n a m e s   =   t h i s . o b j e c t A c t o r . _ o b j . g e t O w n P r o p e r t y N a m e s ( ) ;   
                 }   c a t c h   ( e x )   { }   
   
                 i f   ( ! o p t i o n s . i g n o r e S a f e G e t t e r s )   {   
                         / /   M e r g e   t h e   s a f e   g e t t e r   v a l u e s   i n t o   t h e   e x i s t i n g   p r o p e r t i e s   l i s t .   
                         s a f e G e t t e r V a l u e s   =   t h i s . o b j e c t A c t o r . _ f i n d S a f e G e t t e r V a l u e s ( n a m e s ) ;   
                         s a f e G e t t e r N a m e s   =   O b j e c t . k e y s ( s a f e G e t t e r V a l u e s ) ;   
                         f o r   ( l e t   n a m e   o f   s a f e G e t t e r N a m e s )   {   
                                 i f   ( n a m e s . i n d e x O f ( n a m e )   = = =   - 1 )   {   
                                         n a m e s . p u s h ( n a m e ) ;   
                                 }   
                         }   
                 }   
   
                 i f   ( o p t i o n s . i g n o r e I n d e x e d P r o p e r t i e s   | |   o p t i o n s . i g n o r e N o n I n d e x e d P r o p e r t i e s )   {   
                         l e t   l e n g t h   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( t h i s . o b j e c t A c t o r . _ o b j ,   " l e n g t h " ) ;   
                         i f   ( t y p e o f ( l e n g t h )   ! = =   " n u m b e r " )   {   
                                 / /   P s e u d o   a r r a y s   a r e   f l a g g e d   a s   A r r a y L i k e   i f   t h e y   h a v e   
                                 / /   s u b s e q u e n t   i n d e x e d   p r o p e r t i e s   w i t h o u t   h a v i n g   a n y   l e n g t h   a t t r i b u t e .   
                                 l e n g t h   =   0 ;   
                                 f o r   ( l e t   k e y   o f   n a m e s )   {   
                                         i f   ( i s N a N ( k e y )   | |   k e y   ! =   l e n g t h + + )   {   
                                                 b r e a k ;   
                                         }   
                                 }   
                         }   
   
                         i f   ( o p t i o n s . i g n o r e I n d e x e d P r o p e r t i e s )   {   
                                 n a m e s   =   n a m e s . f i l t e r ( i   = >   {   
                                         / /   U s e   p a r s e F l o a t   i n   o r d e r   t o   r e j e c t   f l o a t s . . .   
                                         / /   ( p a r s e I n t   c o n v e r t s   f l o a t s   t o   i n t e g e r )   
                                         / /   ( N u m b e r ( s t r )   c o n v e r t s   s p a c e s   t o   0 )   
                                         i   =   p a r s e F l o a t ( i ) ;   
                                         r e t u r n   ! N u m b e r . i s I n t e g e r ( i )   | |   i   <   0   | |   i   > =   l e n g t h ;   
                                 } ) ;   
                         }   
   
                         i f   ( o p t i o n s . i g n o r e N o n I n d e x e d P r o p e r t i e s )   {   
                                 n a m e s   =   n a m e s . f i l t e r ( i   = >   {   
                                         i   =   p a r s e F l o a t ( i ) ;   
                                         r e t u r n   N u m b e r . i s I n t e g e r ( i )   & &   i   > =   0   & &   i   <   l e n g t h ;   
                                 } ) ;   
                         }   
                 }   
   
                 i f   ( o p t i o n s . q u e r y )   {   
                         l e t   {   q u e r y   }   =   o p t i o n s ;   
                         q u e r y   =   q u e r y . t o L o w e r C a s e ( ) ;   
                         n a m e s   =   n a m e s . f i l t e r ( n a m e   = >   {   
                                 / /   F i l t e r   o n   a t t r i b u t e   n a m e s   
                                 i f   ( n a m e . t o L o w e r C a s e ( ) . i n c l u d e s ( q u e r y ) )   {   
                                         r e t u r n   t r u e ;   
                                 }   
                                 / /   a n d   t h e n   o n   a t t r i b u t e   v a l u e s   
                                 l e t   d e s c ;   
                                 t r y   {   
                                         d e s c   =   t h i s . _ o b j . g e t O w n P r o p e r t y D e s c r i p t o r ( n a m e ) ;   
                                 }   c a t c h ( e )   { }   
                                 i f   ( d e s c   & &   d e s c . v a l u e   & &   
                                         S t r i n g ( d e s c . v a l u e ) . i n c l u d e s ( q u e r y ) )   {   
                                         r e t u r n   t r u e ;   
                                 }   
                                 r e t u r n   f a l s e ;   
                         } ) ;   
                 }   
   
                 i f   ( o p t i o n s . s o r t )   {   
                         n a m e s . s o r t ( ) ;   
                 }   
   
                 / /   N o w   b u i l d   t h e   d e s c r i p t o r   l i s t   
                 f o r   ( l e t   n a m e   o f   n a m e s )   {   
                         l e t   d e s c   =   t h i s . o b j e c t A c t o r . _ p r o p e r t y D e s c r i p t o r ( n a m e ) ;   
                         i f   ( ! d e s c )   {   
                                 d e s c   =   s a f e G e t t e r V a l u e s [ n a m e ] ;   
                         }   
                         e l s e   i f   ( n a m e   i n   s a f e G e t t e r V a l u e s )   {   
                                 / /   M e r g e   t h e   s a f e   g e t t e r   v a l u e s   i n t o   t h e   e x i s t i n g   p r o p e r t i e s   l i s t .   
                                 l e t   {   g e t t e r V a l u e ,   g e t t e r P r o t o t y p e L e v e l   }   =   s a f e G e t t e r V a l u e s [ n a m e ] ;   
                                 d e s c . g e t t e r V a l u e   =   g e t t e r V a l u e ;   
                                 d e s c . g e t t e r P r o t o t y p e L e v e l   =   g e t t e r P r o t o t y p e L e v e l ;   
                         }   
                         o w n P r o p e r t i e s [ n a m e ]   =   d e s c ;   
                 }   
   
                 t h i s . n a m e s   =   n a m e s ;   
                 t h i s . o w n P r o p e r t i e s   =   o w n P r o p e r t i e s ;   
         }   
         s l i c e ( a R e q u e s t )   {   
                 l e t   {   s t a r t ,   c o u n t   }   =   a R e q u e s t ;   
                 l e t   n a m e s   =   t h i s . n a m e s . s l i c e ( s t a r t ,   s t a r t   +   c o u n t ) ;   
                 l e t   p r o p s   =   { } ;   
                 f o r   ( l e t   n a m e   o f   n a m e s )   {   
                         p r o p s [ n a m e ]   =   t h i s . o w n P r o p e r t i e s [ n a m e ] ;   
                 }   
                 r e t u r n   {   
                         o w n P r o p e r t i e s :   p r o p s   
                 } ;   
         }   
         _ r e s p ( )   {   
                 r e t u r n   {   
                         t y p e :   " p r o p e r t y I t e r a t o r " ,   
                         a c t o r :   t h i s . f u l l A c t o r ,   
                         c o u n t :   t h i s . n a m e s . l e n g t h   
                 } ;   
         }   
 }   
   
 c l a s s   E n v i r o n m e n t A c t o r   e x t e n d s   A c t o r   {   
         c o n s t r u c t o r ( e n v i r o n m e n t ,   p a r e n t )   {   
                 s u p e r ( p a r e n t   i n s t a n c e o f   E n v i r o n m e n t A c t o r   ?   ' p a r e n t '   :   ' e n v '   ,   p a r e n t ) ;   
                 t h i s . _ e n v   =   e n v i r o n m e n t ;   
                 i f   ( t h i s . _ e n v . p a r e n t )   n e w   E n v i r o n m e n t A c t o r ( t h i s . _ e n v . p a r e n t ,   t h i s ) ;   
         }   
         g e t   _ r e s p ( ) {   
                 l e t   r e s p   =   {   
                         a c t o r :   t h i s . f u l l A c t o r   
                 } ;   
                 i f   ( t h i s . _ e n v . t y p e   = =   " d e c l a r a t i v e " )   {   
                         r e s p . t y p e   =   t h i s . _ e n v . c a l l e e   ?   " f u n c t i o n "   :   " b l o c k " ;   
                 }   e l s e   {   
                         r e s p . t y p e   =   t h i s . _ e n v . t y p e ;   
                 }   
                 i f   ( t h i s . _ e n v . t y p e   = =   " o b j e c t "   | |   t h i s . _ e n v . t y p e   = =   " w i t h " )   {   
                         r e s p . o b j e c t   =   t h i s . g e t G r i p ( t h i s . _ e n v . o b j e c t ) ;   
                 }   
                 i f   ( t h i s . _ e n v . c a l l e e )   {   
                         r e s p . f u n c t i o n   =   t h i s . g e t G r i p ( t h i s . _ e n v . c a l l e e ) ;   
                 }   
                 i f   ( t h i s . _ e n v . t y p e   = =   " d e c l a r a t i v e " )   {   
                         r e s p . b i n d i n g s   =   t h i s . b i n d i n g s ( )   
                 }   
                 i f   ( t h i s . p a r e n t )   
                         r e s p . p a r e n t   =   t h i s . p a r e n t . _ r e s p ;   
                 r e t u r n   r e s p ;   
         }   
         b i n d i n g s ( ) {   
                 l e t   b i n d i n g s   =   {   a r g u m e n t s :   [ ] ,   v a r i a b l e s :   { }   } ;   
                 / /   T O D O :   t h i s   p a r t   s h o u l d   b e   r e m o v e d   i n   f a v o r   o f   t h e   c o m m e n t e d - o u t   p a r t   
                 / /   b e l o w   w h e n   g e t V a r i a b l e D e s c r i p t o r   l a n d s   ( b u g   7 2 5 8 1 5 ) .   
                 i f   ( t y p e o f   t h i s . _ e n v . g e t V a r i a b l e   ! =   " f u n c t i o n " )   {   
                         / / i f   ( t y p e o f   t h i s . _ e n v . g e t V a r i a b l e D e s c r i p t o r   ! =   " f u n c t i o n " )   {   
                         r e t u r n   b i n d i n g s ;   
                 }   
   
                 l e t   p a r a m e t e r N a m e s ;   
                 i f   ( t h i s . _ e n v . c a l l e e )   {   
                         p a r a m e t e r N a m e s   =   t h i s . _ e n v . c a l l e e . p a r a m e t e r N a m e s ;   
                 }   e l s e   {   
                         p a r a m e t e r N a m e s   =   [ ] ;   
                 }   
                 f o r   ( l e t   n a m e   o f   p a r a m e t e r N a m e s )   {   
                         l e t   a r g   =   { } ;   
                         l e t   v a l u e   =   t h i s . _ e n v . g e t V a r i a b l e ( n a m e ) ;   
   
                         / /   T O D O :   t h i s   p a r t   s h o u l d   b e   r e m o v e d   i n   f a v o r   o f   t h e   c o m m e n t e d - o u t   p a r t   
                         / /   b e l o w   w h e n   g e t V a r i a b l e D e s c r i p t o r   l a n d s   ( b u g   7 2 5 8 1 5 ) .   
                         l e t   d e s c   =   {   
                                 v a l u e :   v a l u e ,   
                                 c o n f i g u r a b l e :   f a l s e ,   
                                 w r i t a b l e :   ! ( v a l u e   & &   v a l u e . o p t i m i z e d O u t ) ,   
                                 e n u m e r a b l e :   t r u e   
                         } ;   
   
                         / /   l e t   d e s c   =   t h i s . _ e n v . g e t V a r i a b l e D e s c r i p t o r ( n a m e ) ;   
                         l e t   d e s c F o r m   =   {   
                                 e n u m e r a b l e :   t r u e ,   
                                 c o n f i g u r a b l e :   d e s c . c o n f i g u r a b l e   
                         } ;   
                         i f   ( " v a l u e "   i n   d e s c )   {   
                                 d e s c F o r m . v a l u e   =   t h i s . g e t G r i p ( d e s c . v a l u e ) ;   
                                 d e s c F o r m . w r i t a b l e   =   d e s c . w r i t a b l e ;   
                         }   e l s e   {   
                                 d e s c F o r m . g e t   =   t h i s . g e t G r i p ( d e s c . g e t ) ;   
                                 d e s c F o r m . s e t   =   t h i s . g e t G r i p ( d e s c . s e t ) ;   
                         }   
                         a r g [ n a m e ]   =   d e s c F o r m ;   
                         b i n d i n g s . a r g u m e n t s . p u s h ( a r g ) ;   
                 }   
   
                 f o r   ( l e t   n a m e   o f   t h i s . _ e n v . n a m e s ( ) )   {   
                         i f   ( b i n d i n g s . a r g u m e n t s . s o m e ( f u n c t i o n   e x i s t s ( e l e m e n t )   {   
                                         r e t u r n   ! ! e l e m e n t [ n a m e ] ;   
                                 } ) )   {   
                                 c o n t i n u e ;   
                         }   
   
                         l e t   v a l u e   =   t h i s . _ e n v . g e t V a r i a b l e ( n a m e ) ;   
   
                         / /   T O D O :   t h i s   p a r t   s h o u l d   b e   r e m o v e d   i n   f a v o r   o f   t h e   c o m m e n t e d - o u t   p a r t   
                         / /   b e l o w   w h e n   g e t V a r i a b l e D e s c r i p t o r   l a n d s .   
                         l e t   d e s c   =   {   
                                 v a l u e :   v a l u e ,   
                                 c o n f i g u r a b l e :   f a l s e ,   
                                 w r i t a b l e :   ! ( v a l u e   & &   
                                 ( v a l u e . o p t i m i z e d O u t   | |   
                                 v a l u e . u n i n i t i a l i z e d   | |   
                                 v a l u e . m i s s i n g A r g u m e n t s ) ) ,   
                                 e n u m e r a b l e :   t r u e   
                         } ;   
   
                         / / l e t   d e s c   =   t h i s . _ e n v . g e t V a r i a b l e D e s c r i p t o r ( n a m e ) ;   
                         l e t   d e s c F o r m   =   {   
                                 e n u m e r a b l e :   t r u e ,   
                                 c o n f i g u r a b l e :   d e s c . c o n f i g u r a b l e   
                         } ;   
                         i f   ( " v a l u e "   i n   d e s c )   {   
                                 d e s c F o r m . v a l u e   =   t h i s . g e t G r i p ( d e s c . v a l u e ) ;   
                                 d e s c F o r m . w r i t a b l e   =   d e s c . w r i t a b l e ;   
                         }   e l s e   {   
                                 d e s c F o r m . g e t   =   t h i s . g e t G r i p ( d e s c . g e t   | |   u n d e f i n e d ) ;   
                                 d e s c F o r m . s e t   =   t h i s . g e t G r i p ( d e s c . s e t   | |   u n d e f i n e d ) ;   
                         }   
                         b i n d i n g s . v a r i a b l e s [ n a m e ]   =   d e s c F o r m ;   
                 }   
                 r e t u r n   b i n d i n g s ;   
         }   
 }   
   
 c l a s s   F r a m e A c t o r   e x t e n d s   A c t o r   {   
         c o n s t r u c t o r ( f r a m e ,   p a r e n t )   {   
                 s u p e r ( p a r e n t   ?   ' o l d e r '   :   ' f r a m e ' ,   p a r e n t ) ;   
                 t h i s . _ f r a m e   =   f r a m e ;   
                 t h i s . _ d e p t h   =   p a r e n t   ?   p a r e n t . _ d e p t h   +   1   :   0 ;   
                 i f   ( t h i s . _ f r a m e . o l d e r )   
                         n e w   F r a m e A c t o r ( t h i s . _ f r a m e . o l d e r ,   t h i s ) ;   
         }   
         g e t   _ r e s p ( ) {   
                 l e t   r e s p   =   {   
                         a c t o r :   t h i s . f u l l A c t o r ,   
                         t y p e :   t h i s . _ f r a m e . t y p e ,   
                         d e p t h :   t h i s . _ d e p t h ,   
                         ' t h i s ' :   t h i s . g e t G r i p ( t h i s . _ f r a m e . t h i s ) ,   
                         a r g u m e n t s :   t h i s . _ a r g s ( )   
                 } ;   
                 i f   ( t h i s . _ f r a m e . t y p e )   {   
                         r e s p . c a l l e e   =   t h i s . g e t G r i p ( t h i s . _ f r a m e . c a l l e e ) ;   
                 }   
                 i f   ( t h i s . _ f r a m e . e n v i r o n m e n t )   {   
                         r e s p . e n v i r o n m e n t   =   ( n e w   E n v i r o n m e n t A c t o r ( t h i s . _ f r a m e . e n v i r o n m e n t ,   t h i s ) ) . _ r e s p ;   
                 }   
                 i f   ( t h i s . _ f r a m e . s c r i p t )   {   
                         l e t   s c r i p t   =   t h i s . _ f r a m e . s c r i p t ,   
                                 l o c a t i o n   =   s c r i p t . g e t O f f s e t L o c a t i o n ( t h i s . _ f r a m e . o f f s e t ) ,   
                                 s o u r c e R e s p   =   a c t o r M a n a g e r . g e t A c t o r ( ' s o u r c e ' ) . _ s o u r c e s M a p . g e t ( s c r i p t . s o u r c e ) . _ r e s p ;   
                         r e s p . w h e r e   =   {   
                                 s o u r c e :   s o u r c e R e s p ,   
                                 l i n e :   l o c a t i o n . l i n e N u m b e r ,   
                                 c o l u m n :   l o c a t i o n . c o l u m n N u m b e r   
                         } ;   
                         r e s p . s o u r c e   =   s o u r c e R e s p ;   
                 }   
                 i f   ( ! t h i s . _ f r a m e . o l d e r )   {   
                         r e s p . o l d e s t   =   t r u e ;   
                 }   
   
                         r e t u r n   r e s p ;   
         }   
         _ a r g s ( )   {   
                 i f   ( ! t h i s . _ f r a m e . a r g u m e n t s )   {   
                         r e t u r n   [ ] ;   
                 }   
   
                 r e t u r n   t h i s . _ f r a m e . a r g u m e n t s . m a p ( a r g   = >   t h i s . g e t G r i p ( a r g ) ) ;   
         }   
 }   
   
 c l a s s   A d d o n A c t o r   e x t e n d s   A c t o r   {   
         c o n s t r u c t o r ( a c t o r N a m e )   {   
                 l e t   s e r v e r A c t o r   =   n e w   A c t o r ( d b g _ b i n d i n g . d e b u g g e r N a m e ) ,   
                         c o n n A c t o r   =   n e w   A c t o r ( ' c o n n 1 ' ,   s e r v e r A c t o r ) ;   
                 s u p e r ( a c t o r N a m e ,   c o n n A c t o r ) ;   
                 n e w   T h r e a d A c t o r ( ) ;   
         }   
         a t t a c h ( a R e q u e s t ) {   
                 r e t u r n   {   
                         t y p e :   " t a b A t t a c h e d " ,   
                         t h r e a d A c t o r :   a c t o r M a n a g e r . t h r e a d . f u l l A c t o r ,   
                         t r a i t s :   { r e c o n f i g u r e :   f a l s e }   
                 }   
         }   
         d e t a c h ( a R e q u e s t )   {   
                 r e t u r n   {   
                         " t y p e " :   " d e t a c h e d "   
                 }   
         }   
         r e c o n f i g u r e ( a R e q u e s t )   {   
                 r e t u r n   { } ;   
         }   
         l i s t W o r k e r s ( a R e q u e s t )   {   
                 r e t u r n   {   f r o m :   t h i s . f u l l A c t o r ,   " w o r k e r s " : [ ]   }   
         }   
         f o c u s ( a R e q u e s t )   {   
               r e t u r n   { }   
         }   
 }   
   
 e x p o r t   f u n c t i o n   n e w M e s s a g e   ( m s g )   {   
         v a r   i n R e q u e s t ,   
                 o u t R e q u e s t ,   
                 a c t o r N a m e ,   
                 a c t o r ,   
                 h a n d l e r ;   
         t r y   {   
                 i f   ( m s g   = = =   n u l l )   {   / /   d e b u g g e r   c l i e n t   c l o s e   s o c k e t   
                         / /   e m u l a t e   d e t a c h   w i t h o u t   s e n d i n g   r e s p o n s e s   t o   d e t a c h e d   c l i e n t   
                         / /   { " t o " : " t h r e a d " , " t y p e " : " d e t a c h " }   
                         a c t o r   =   a c t o r M a n a g e r . g e t A c t o r ( ' t h r e a d ' )   
                         i f   ( a c t o r )   {   
                                 a c t o r . d e t a c h ( )   
                         }   
                         r e t u r n   
                 }   
                 i n R e q u e s t   =   ( t y p e o f   m s g   = = =   " s t r i n g " )   ?   J S O N . p a r s e ( m s g )   :   m s g ;   
                 a c t o r N a m e   =   i n R e q u e s t . t o ;   
                 a c t o r   =   a c t o r M a n a g e r . g e t A c t o r ( a c t o r N a m e ) ;   
                 i f   ( a c t o r )   {   
                         h a n d l e r   =   a c t o r [ i n R e q u e s t . t y p e ] ;   
                         o u t R e q u e s t   =   h a n d l e r   ?   a c t o r [ i n R e q u e s t . t y p e ] ( i n R e q u e s t )   :   { } ;   
                         i f   ( ! h a n d l e r )   
                                 D e v T o o l s U t i l s . r e p o r t E x c e p t i o n ( ' n e w M e s s a g e :   '   +   i n R e q u e s t . t y p e   +   '   n o t   f o u n d   i n   '   +   a c t o r N a m e   +   '   C l a s s   '   +   a c t o r . c o n s t r u c t o r . n a m e ,   m s g ) ;   
                         i f   ( o u t R e q u e s t )   {   
                                 o u t R e q u e s t . f r o m   =   a c t o r N a m e ;   
                                 d b g _ b i n d i n g . s e n d ( o u t R e q u e s t ) ;   
                         }   e l s e   {   
                                 D e v T o o l s U t i l s . r e p o r t E x c e p t i o n ( ' n e w M e s s a g e :   '   +   a c t o r N a m e   +   ' . '   +   i n R e q u e s t . t y p e   +   ' !   o u t R e q u e s t ' ,   m s g ) ;   
                         }   
                 }   e l s e   {   
                         D e v T o o l s U t i l s . r e p o r t E x c e p t i o n ( ' n e w M e s s a g e :   '   +   a c t o r N a m e   +   '   n o t   f o u n d ' ,   m s g ) ;   
                 }   
         }   c a t c h ( e )   {   
                 D e v T o o l s U t i l s . r e p o r t E x c e p t i o n ( ' n e w M e s s a g e ' ,   e ) ;   
         }   
 }   
   
 / / a v a i l a b l e   l o g   l e v e l s   
 / *   
 { c a t e g o r y :   " w e b d e v " ,     l e v e l :   " e r r o r " }   
 { c a t e g o r y :   " w e b d e v " ,     l e v e l :   " w a r n " }   
 { c a t e g o r y :   " w e b d e v " ,     l e v e l :   " i n f o " }   
 { c a t e g o r y :   " w e b d e v " ,     l e v e l :   " l o g " }   
 { c a t e g o r y :   " s e r v e r " ,     l e v e l :   " e r r o r " }   
 { c a t e g o r y :   " s e r v e r " ,     l e v e l :   " w a r n " }   
 { c a t e g o r y :   " s e r v e r " ,     l e v e l :   " i n f o " }   
 { c a t e g o r y :   " s e r v e r " ,     l e v e l :   " l o g " }   
 { c a t e g o r y :   " j s " ,             l e v e l :   " e r r o r " }   
 { c a t e g o r y :   " j s " ,             l e v e l :   " w a r n " }   
 { c a t e g o r y :   " c s s " ,           l e v e l :   " e r r o r " }   
 { c a t e g o r y :   " c s s " ,           l e v e l :   " w a r n " }   
 { c a t e g o r y :   " n e t w o r k " ,   l e v e l :   " e r r o r " }   
 { c a t e g o r y :   " n e t w o r k " ,   l e v e l :   " w a r n " }   
 { c a t e g o r y :   " n e t w o r k " ,   l e v e l :   " l o g " }   
 * /   
 l e t   c o n s o l e M e s s a g e R e s o l v e r   =   ( m s g )   = >   ( { l e v e l :   " l o g " ,   c a t e g o r y :   " w e b d e v " ,   m s g :   m s g ,   t i m e S t a m p :   D a t e . n o w ( ) } ) ;   
   
 e x p o r t   f u n c t i o n   n e w C o n s o l e M e s s a g e ( _ m s g )   {   
         l e t   { c a t e g o r y ,   l e v e l ,   m s g ,   t i m e S t a m p }   =   c o n s o l e M e s s a g e R e s o l v e r ( _ m s g ) ;   
         d b g _ b i n d i n g . s e n d ( {   
                 f r o m :   a c t o r M a n a g e r . c o n s o l e . _ a c t o r ,   
                 t y p e :   " c o n s o l e A P I C a l l " ,   
                 m e s s a g e :   {   
                         " a r g u m e n t s " :   [ a c t o r M a n a g e r . c o n s o l e . g e t G r i p ( m s g ) ] ,   
                         " c o l u m n N u m b e r " :   1 ,   
                         " c o u n t e r " :   n u l l ,   
                         " f i l e n a m e " :   " d e b u g g e r   e v a l   c o d e " ,   
                         " f u n c t i o n N a m e " :   " " ,   
                         " g r o u p N a m e " :   " " ,   
                         " l e v e l " :   l e v e l ,   
                         " l i n e N u m b e r " :   1 ,   
                         " p r i v a t e " :   f a l s e ,   
                         " s t y l e s " :   [ ] ,   
                         " t i m e S t a m p " :   t i m e S t a m p ,   
                         " t i m e r " :   n u l l ,   
                         " w o r k e r T y p e " :   " n o n e " ,   
                         " c a t e g o r y " :   c a t e g o r y   
                 }   
         } ) ;   
 }   
   
 e x p o r t   f u n c t i o n   i n i t ( e n g N o ,   i n t e r r u p t O n N e x t )   {   
         i f   ( ! a c t o r M a n a g e r )   {   
                 a c t o r M a n a g e r   =   n e w   A c t o r M a n a g e r ( e n g N o ) ;   
                 a c t o r M a n a g e r . i n i t ( ) ;   
         }   
         l e t   s o u r c e s   =   n e w   S o u r c e s A c t o r ( ) ;   
         i f   ( d b g _ b i n d i n g . l i s t e n )   {   
                 a c t o r M a n a g e r . t h r e a d . a t t a c h ( ) ;   
         }   
   
         i f   ( i n t e r r u p t O n N e x t )   {   
                 l e t   o n E n t e r F r a m e   =   ( a F r a m e )   = >   {   
                         r e t u r n   a c t o r M a n a g e r . t h r e a d . _ p a u s e A n d R e s p o n d ( a F r a m e ,   { t y p e :   " i n t e r r u p t e d " ,   o n N e x t :   t r u e } ) ;   
                 } ;   
                 a c t o r M a n a g e r . t h r e a d . d b g . o n E n t e r F r a m e   =   o n E n t e r F r a m e ;   
         }   
         i f   ( d b g _ b i n d i n g . l i s t e n )   {   
                 a c t o r M a n a g e r . t h r e a d . d b g . f i n d S c r i p t s ( ) . f o r E a c h ( f u n c t i o n   ( s c r i p t )   {   
                         l e t   r e s p   =   s o u r c e s . _ a d d S o u r c e ( s c r i p t . s o u r c e ) ;   
                         i f   ( r e s p )   {   
                                 d b g _ b i n d i n g . s e n d ( {   
                                         f r o m :   a c t o r M a n a g e r . t h r e a d . f u l l A c t o r ,   
                                         t y p e :   " n e w S o u r c e " ,   
                                         s o u r c e :   r e s p   
                                 } ) ;   
                         }   
                 } ) ;   
         }   
 }   
   
 e x p o r t   f u n c t i o n   u n i n i t ( )   {   
         i f   ( d b g _ b i n d i n g . p a u s e d )   {   
                 / / a c t o r M a n a g e r . t h r e a d . d b g . e n a b l e d   =   f a l s e ;   
                 l e t   r e s p   =   a c t o r M a n a g e r . t h r e a d . r e s u m e ( { } ) ;   
   
                 r e s p . f r o m   =   a c t o r M a n a g e r . t h r e a d . f u l l A c t o r ;   
                 d b g _ b i n d i n g . s e n d ( r e s p ) ;   
         }   
   
         d b g _ b i n d i n g . s e n d ( {   
                 f r o m :   a c t o r M a n a g e r . a d d o n . f u l l A c t o r ,   
                 " t y p e " :   " t a b N a v i g a t e d " ,   
                 " n a t i v e C o n s o l e A P I " :   t r u e ,   
                 " s t a t e " :   " s t a r t " ,   
                 " i s F r a m e S w i t c h i n g " :   f a l s e   
         } ) ;   
   
         d b g _ b i n d i n g . s e n d ( {   
                 f r o m :   a c t o r M a n a g e r . a d d o n . f u l l A c t o r ,   
                 " t y p e " :   " t a b N a v i g a t e d " ,   
                 " n a t i v e C o n s o l e A P I " :   t r u e ,   
                 " s t a t e " :   " s t o p " ,   
                 " i s F r a m e S w i t c h i n g " :   f a l s e   
         } ) ;   
 }   
   
 / * *   
   *   l i s t   o f   c o n s o l e   a d d i t i o n a l   c o m m a n d s   
   *   p r o p e r t y   h e l p   c o n t a i n s   w e l c o m e   m e s s a g e   
   *   o t h e r   p r o p e r t i e s   m u s t   b e   a n   o b j e c t s   w i t h   2   p r o p e r t i e s   
   *   v a l u e   -   v a l u e   f o r   c o n s o l e   
   *   d e s c r i p t i o n ( o p t i o n a l )   -   d e s c r i p t i o n   f o r   h e l p ( )   c o n s o l e   f u n c t i o n   
   *   
   *   @ t y p e   { { h e l p :   s t r i n g | F u n c t i o n : s t r i n g ,   t e s t :   { c o m m a n d :   F u n c t i o n ,   d e s c r i p t i o n :   s t r i n g } } }   
   * /   
 e x p o r t   f u n c t i o n   s e t C o n s o l e C o m m a n d s ( a C o m m a n d s )   {   
         a c t o r M a n a g e r . c o n s o l e . c o n s o l e C o m m a n d s   =   a C o m m a n d s ;   
 }   
   
 e x p o r t   f u n c t i o n   s e t C o n s o l e M e s s a g e R e s o l v e r ( a R e s o l v e r )   {   
         c o n s o l e M e s s a g e R e s o l v e r   =   a R e s o l v e r ;   
 }   
   
   
 e x p o r t   f u n c t i o n   d o I n t e r u p t ( )   {   
         l e t   m s g ;   
         w h i l e   ( m s g   =   d b g _ b i n d i n g . r e a d ( t r u e ) )   {   
                 n e w M e s s a g e ( m s g ) ;   
                 w h i l e   ( m s g   =   d b g _ b i n d i n g . r e a d ( f a l s e ) )   {   
                         n e w C o n s o l e M e s s a g e ( m s g ) ;   
                 }   
         } ;   
         w h i l e   ( m s g   =   d b g _ b i n d i n g . r e a d ( f a l s e ) )   {   
                 n e w C o n s o l e M e s s a g e ( m s g ) ;   
         }   
 }   
   
 p r o c e s s . d b g   =   {   
         d o I n t e r u p t :   d o I n t e r u p t ,   
         i n i t :   i n i t ,   
         u n i n i t :   u n i n i t   
 } ; �!  P   ��
 D E V T O O L S / D E V T O O L S U T I L S . J S       0	        " u s e   s t r i c t " ;   
 l e t   { l o g E r r o r }   =   p r o c e s s . b i n d i n g ( ' d e b u g g e r ' ) ;   
   
 / * *   
   *   T u r n   t h e   e r r o r   | a E r r o r |   i n t o   a   s t r i n g ,   w i t h o u t   f a i l .   
   * /   
 f u n c t i o n   s a f e E r r o r S t r i n g ( a E r r o r )   {   
         t r y   {   
                 l e t   e r r o r S t r i n g   =   a E r r o r . t o S t r i n g ( ) ;   
                 i f   ( t y p e o f   e r r o r S t r i n g   = =   " s t r i n g " )   {   
                         / /   A t t e m p t   t o   a t t a c h   a   s t a c k   t o   | e r r o r S t r i n g | .   I f   i t   t h r o w s   a n   e r r o r ,   o r   
                         / /   i s n ' t   a   s t r i n g ,   d o n ' t   u s e   i t .   
                         t r y   {   
                                 i f   ( a E r r o r . s t a c k )   {   
                                         l e t   s t a c k   =   a E r r o r . s t a c k . t o S t r i n g ( ) ;   
                                         i f   ( t y p e o f   s t a c k   = =   " s t r i n g " )   {   
                                                 e r r o r S t r i n g   + =   " \ n S t a c k :   "   +   s t a c k ;   
                                         }   
                                 }   
                         }   c a t c h   ( e e )   {   }   
   
                         / /   A p p e n d   a d d i t i o n a l   l i n e   a n d   c o l u m n   n u m b e r   i n f o r m a t i o n   t o   t h e   o u t p u t ,   
                         / /   s i n c e   i t   m i g h t   n o t   b e   p a r t   o f   t h e   s t r i n g i f i e d   e r r o r .   
                         i f   ( t y p e o f   a E r r o r . l i n e N u m b e r   = =   " n u m b e r "   & &   t y p e o f   a E r r o r . c o l u m n N u m b e r   = =   " n u m b e r " )   {   
                                 e r r o r S t r i n g   + =   " L i n e :   "   +   a E r r o r . l i n e N u m b e r   +   " ,   c o l u m n :   "   +   a E r r o r . c o l u m n N u m b e r ;   
                         }   
   
                         r e t u r n   e r r o r S t r i n g ;   
                 }   
         }   c a t c h   ( e e )   {   }   
   
         / /   W e   f a i l e d   t o   f i n d   a   g o o d   e r r o r   d e s c r i p t i o n ,   s o   d o   t h e   n e x t   b e s t   t h i n g .   
         r e t u r n   O b j e c t . p r o t o t y p e . t o S t r i n g . c a l l ( a E r r o r ) ;   
 } ;   
   
 / * *   
   *   R e p o r t   t h a t   | a W h o |   t h r e w   a n   e x c e p t i o n ,   | a E x c e p t i o n | .   
   * /   
 e x p o r t   f u n c t i o n   r e p o r t E x c e p t i o n ( a W h o ,   a E x c e p t i o n )   {   
         l e t   m s g   =   a W h o   +   "   t h r e w   a n   e x c e p t i o n :   "   +   s a f e E r r o r S t r i n g ( a E x c e p t i o n ) ;   
         l o g E r r o r ( m s g ) ;   
 } ;   
   
 / * *   
   *   S a f e l y   g e t   t h e   p r o p e r t y   v a l u e   f r o m   a   D e b u g g e r . O b j e c t   f o r   a   g i v e n   k e y .   W a l k s   
   *   t h e   p r o t o t y p e   c h a i n   u n t i l   t h e   p r o p e r t y   i s   f o u n d .   
   *   
   *   @ p a r a m   D e b u g g e r . O b j e c t   a O b j e c t   
   *                 T h e   D e b u g g e r . O b j e c t   t o   g e t   t h e   v a l u e   f r o m .   
   *   @ p a r a m   S t r i n g   a K e y   
   *                 T h e   k e y   t o   l o o k   f o r .   
   *   @ r e t u r n   A n y   
   * /   
 e x p o r t   f u n c t i o n   g e t P r o p e r t y ( a O b j ,   a K e y )   {   
         l e t   r o o t   =   a O b j ;   
         t r y   {   
                 d o   {   
                         c o n s t   d e s c   =   a O b j . g e t O w n P r o p e r t y D e s c r i p t o r ( a K e y ) ;   
                         i f   ( d e s c )   {   
                                 i f   ( " v a l u e "   i n   d e s c )   {   
                                         r e t u r n   d e s c . v a l u e ;   
                                 }   
                                 / /   C a l l   t h e   g e t t e r   i f   i t ' s   s a f e .   
                                 r e t u r n   h a s S a f e G e t t e r ( d e s c )   ?   d e s c . g e t . c a l l ( r o o t ) . r e t u r n   :   u n d e f i n e d ;   
                         }   
                         a O b j   =   a O b j . p r o t o ;   
                 }   w h i l e   ( a O b j ) ;   
         }   c a t c h   ( e )   {   
                 / /   I f   a n y t h i n g   g o e s   w r o n g   r e p o r t   t h e   e r r o r   a n d   r e t u r n   u n d e f i n e d .   
                 / / e x p o r t s . r e p o r t E x c e p t i o n ( " g e t P r o p e r t y " ,   e ) ;   
         }   
         r e t u r n   u n d e f i n e d ;   
 } ;   
   
 / * *   
   *   D e t e r m i n e s   i f   a   d e s c r i p t o r   h a s   a   g e t t e r   w h i c h   d o e s n ' t   c a l l   i n t o   J a v a S c r i p t .   
   *   
   *   @ p a r a m   O b j e c t   a D e s c   
   *                 T h e   d e s c r i p t o r   t o   c h e c k   f o r   a   s a f e   g e t t e r .   
   *   @ r e t u r n   B o o l e a n   
   *                   W h e t h e r   a   s a f e   g e t t e r   w a s   f o u n d .   
   * /   
 e x p o r t   f u n c t i o n   h a s S a f e G e t t e r ( a D e s c )   {   
         / /   S c r i p t e d   f u n c t i o n s   t h a t   a r e   C C W s   w i l l   n o t   a p p e a r   s c r i p t e d   u n t i l   a f t e r   
         / /   u n w r a p p i n g .   
         t r y   {   
                 l e t   f n   =   a D e s c . g e t . u n w r a p ( ) ;   
                 r e t u r n   f n   & &   f n . c a l l a b l e   & &   f n . c l a s s   = =   " F u n c t i o n "   & &   f n . s c r i p t   = = =   u n d e f i n e d ;   
         }   c a t c h ( e )   {   
                 / /   A v o i d   e x c e p t i o n   ' O b j e c t   i n   c o m p a r t m e n t   m a r k e d   a s   i n v i s i b l e   t o   D e b u g g e r '   
                 r e t u r n   f a l s e ;   
         }   
 } ;   
   
 / /   C a l l s   t h e   p r o p e r t y   w i t h   t h e   g i v e n   ` n a m e `   o n   t h e   g i v e n   ` o b j e c t ` ,   w h e r e   
 / /   ` n a m e `   i s   a   s t r i n g ,   a n d   ` o b j e c t `   a   D e b u g g e r . O b j e c t   i n s t a n c e .   
 / / /   
 / /   T h i s   f u n c t i o n   u s e s   o n l y   t h e   D e b u g g e r . O b j e c t   A P I   t o   c a l l   t h e   p r o p e r t y .   I t   
 / /   a v o i d s   t h e   u s e   o f   u n s a f e D e f e r e n c e .   T h i s   i s   u s e f u l   f o r   e x a m p l e   i n   w o r k e r s ,   
 / /   w h e r e   u n s a f e D e r e f e r e n c e   w i l l   r e t u r n   a n   o p a q u e   s e c u r i t y   w r a p p e r   t o   t h e   
 / /   r e f e r e n t .   
 e x p o r t   f u n c t i o n   c a l l P r o p e r t y O n O b j e c t ( o b j e c t ,   n a m e )   {   
     / /   F i n d   t h e   p r o p e r t y .   
     l e t   d e s c r i p t o r ;   
     l e t   p r o t o   =   o b j e c t ;   
     d o   {   
         d e s c r i p t o r   =   p r o t o . g e t O w n P r o p e r t y D e s c r i p t o r ( n a m e ) ;   
         i f   ( d e s c r i p t o r   ! = =   u n d e f i n e d )   {   
             b r e a k ;   
         }   
         p r o t o   =   p r o t o . p r o t o ;   
     }   w h i l e   ( p r o t o   ! = =   n u l l ) ;   
     i f   ( d e s c r i p t o r   = = =   u n d e f i n e d )   {   
         t h r o w   n e w   E r r o r ( " N o   s u c h   p r o p e r t y " ) ;   
     }   
     l e t   v a l u e   =   d e s c r i p t o r . v a l u e ;   
     i f   ( t y p e o f   v a l u e   ! = =   " o b j e c t "   | |   v a l u e   = = =   n u l l   | |   ! ( " c a l l a b l e "   i n   v a l u e ) )   {   
         t h r o w   n e w   E r r o r ( " N o t   a   c a l l a b l e   o b j e c t . " ) ;   
     }   
   
     / /   C a l l   t h e   p r o p e r t y .   
     l e t   r e s u l t   =   v a l u e . c a l l ( o b j e c t ) ;   
     i f   ( r e s u l t   = = =   n u l l )   {   
         t h r o w   n e w   E r r o r ( " C o d e   w a s   t e r m i n a t e d . " ) ;   
     }   
     i f   ( " t h r o w "   i n   r e s u l t )   {   
         t h r o w   r e s u l t . t h r o w ;   
     }   
     r e t u r n   r e s u l t . r e t u r n ;   
 }   
   
   
 / / e x p o r t s . c a l l P r o p e r t y O n O b j e c t   =   c a l l P r o p e r t y O n O b j e c t ;   
   ,�  `   ��
 D E V T O O L S / J S - P R O P E R T Y - P R O V I D E R . J S         0	        " u s e   s t r i c t " ;   
 i m p o r t   *   a s   D e v T o o l s U t i l s   f r o m   ' D e v T o o l s / D e v T o o l s U t i l s . j s ' ;   
   
 / / t o d o   
 / / i f   ( ! i s W o r k e r )   {   
 / /         l o a d e r . l a z y I m p o r t e r ( t h i s ,   " P a r s e r " ,   " r e s o u r c e : / / d e v t o o l s / s h a r e d / P a r s e r . j s m " ) ;   
 / / }   
   
   
 / /   P r o v i d e   a n   e a s y   w a y   t o   b a i l   o u t   o f   e v e n   a t t e m p t i n g   a n   a u t o c o m p l e t i o n   
 / /   i f   a n   o b j e c t   h a s   w a y   t o o   m a n y   p r o p e r t i e s .   P r o t e c t s   a g a i n s t   l a r g e   o b j e c t s   
 / /   w i t h   n u m e r i c   v a l u e s   t h a t   w o u l d n ' t   b e   t a l l i e d   t o w a r d s   M A X _ A U T O C O M P L E T I O N S .   
 e x p o r t   c o n s t   M A X _ A U T O C O M P L E T E _ A T T E M P T S   =   1 0 0 0 0 0 ;   
 / /   P r e v e n t   i t e r a t i n g   o v e r   t o o   m a n y   p r o p e r t i e s   d u r i n g   a u t o c o m p l e t e   s u g g e s t i o n s .   
 e x p o r t   c o n s t   M A X _ A U T O C O M P L E T I O N S   =   1 5 0 0 ;   
   
 c o n s t   S T A T E _ N O R M A L   =   0 ;   
 c o n s t   S T A T E _ Q U O T E   =   2 ;   
 c o n s t   S T A T E _ D Q U O T E   =   3 ;   
   
 c o n s t   O P E N _ B O D Y   =   " { [ ( " . s p l i t ( " " ) ;   
 c o n s t   C L O S E _ B O D Y   =   " } ] ) " . s p l i t ( " " ) ;   
 c o n s t   O P E N _ C L O S E _ B O D Y   =   {   
         " { " :   " } " ,   
         " [ " :   " ] " ,   
         " ( " :   " ) "   
 } ;   
   
 f u n c t i o n   h a s A r r a y I n d e x ( s t r )   {   
         r e t u r n   / \ [ \ d + \ ] $ / . t e s t ( s t r ) ;   
 }   
   
 / * *   
   *   A n a l y s e s   a   g i v e n   s t r i n g   t o   f i n d   t h e   l a s t   s t a t e m e n t   t h a t   i s   i n t e r e s t i n g   f o r   
   *   l a t e r   c o m p l e t i o n .   
   *   
   *   @ p a r a m       s t r i n g   a S t r   
   *                     A   s t r i n g   t o   a n a l y s e .   
   *   
   *   @ r e t u r n s   o b j e c t   
   *                     I f   t h e r e   w a s   a n   e r r o r   i n   t h e   s t r i n g   d e t e c t e d ,   t h e n   a   o b j e c t   l i k e   
   *   
   *                         {   e r r :   " E r r o r M e s s s a g e "   }   
   *   
   *                     i s   r e t u r n e d ,   o t h e r w i s e   a   o b j e c t   l i k e   
   *   
   *                         {   
   *                             s t a t e :   S T A T E _ N O R M A L | S T A T E _ Q U O T E | S T A T E _ D Q U O T E ,   
   *                             s t a r t P o s :   i n d e x   o f   w h e r e   t h e   l a s t   s t a t e m e n t   b e g i n s   
   *                         }   
   * /   
 f u n c t i o n   f i n d C o m p l e t i o n B e g i n n i n g ( a S t r )   {   
         l e t   b o d y S t a c k   =   [ ] ;   
   
         l e t   s t a t e   =   S T A T E _ N O R M A L ;   
         l e t   s t a r t   =   0 ;   
         l e t   c ;   
         f o r   ( l e t   i   =   0 ;   i   <   a S t r . l e n g t h ;   i + + )   {   
                 c   =   a S t r [ i ] ;   
   
                 s w i t c h   ( s t a t e )   {   
                         / /   N o r m a l   J S   s t a t e .   
                         c a s e   S T A T E _ N O R M A L :   
                                 i f   ( c   = =   ' " ' )   {   
                                         s t a t e   =   S T A T E _ D Q U O T E ;   
                                 }   
                                 e l s e   i f   ( c   = =   " ' " )   {   
                                         s t a t e   =   S T A T E _ Q U O T E ;   
                                 }   
                                 e l s e   i f   ( c   = =   " ; " )   {   
                                         s t a r t   =   i   +   1 ;   
                                 }   
                                 e l s e   i f   ( c   = =   "   " )   {   
                                         s t a r t   =   i   +   1 ;   
                                 }   
                                 e l s e   i f   ( O P E N _ B O D Y . i n d e x O f ( c )   ! =   - 1 )   {   
                                         b o d y S t a c k . p u s h ( {   
                                                 t o k e n :   c ,   
                                                 s t a r t :   s t a r t   
                                         } ) ;   
                                         s t a r t   =   i   +   1 ;   
                                 }   
                                 e l s e   i f   ( C L O S E _ B O D Y . i n d e x O f ( c )   ! =   - 1 )   {   
                                         v a r   l a s t   =   b o d y S t a c k . p o p ( ) ;   
                                         i f   ( ! l a s t   | |   O P E N _ C L O S E _ B O D Y [ l a s t . t o k e n ]   ! =   c )   {   
                                                 r e t u r n   {   
                                                         e r r :   " s y n t a x   e r r o r "   
                                                 } ;   
                                         }   
                                         i f   ( c   = =   " } " )   {   
                                                 s t a r t   =   i   +   1 ;   
                                         }   
                                         e l s e   {   
                                                 s t a r t   =   l a s t . s t a r t ;   
                                         }   
                                 }   
                                 b r e a k ;   
   
                         / /   D o u b l e   q u o t e   s t a t e   >   "   <   
                         c a s e   S T A T E _ D Q U O T E :   
                                 i f   ( c   = =   " \ \ " )   {   
                                         i + + ;   
                                 }   
                                 e l s e   i f   ( c   = =   " \ n " )   {   
                                         r e t u r n   {   
                                                 e r r :   " u n t e r m i n a t e d   s t r i n g   l i t e r a l "   
                                         } ;   
                                 }   
                                 e l s e   i f   ( c   = =   ' " ' )   {   
                                         s t a t e   =   S T A T E _ N O R M A L ;   
                                 }   
                                 b r e a k ;   
   
                         / /   S i n g l e   q u o t e   s t a t e   >   '   <   
                         c a s e   S T A T E _ Q U O T E :   
                                 i f   ( c   = =   " \ \ " )   {   
                                         i + + ;   
                                 }   
                                 e l s e   i f   ( c   = =   " \ n " )   {   
                                         r e t u r n   {   
                                                 e r r :   " u n t e r m i n a t e d   s t r i n g   l i t e r a l "   
                                         } ;   
                                 }   
                                 e l s e   i f   ( c   = =   " ' " )   {   
                                         s t a t e   =   S T A T E _ N O R M A L ;   
                                 }   
                                 b r e a k ;   
                 }   
         }   
   
         r e t u r n   {   
                 s t a t e :   s t a t e ,   
                 s t a r t P o s :   s t a r t   
         } ;   
 }   
   
 / * *   
   *   P r o v i d e s   a   l i s t   o f   p r o p e r t i e s ,   t h a t   a r e   p o s s i b l e   m a t c h e s   b a s e d   o n   t h e   p a s s e d   
   *   D e b u g g e r . E n v i r o n m e n t / D e b u g g e r . O b j e c t   a n d   i n p u t V a l u e .   
   *   
   *   @ p a r a m   o b j e c t   a D b g O b j e c t   
   *                 W h e n   t h e   d e b u g g e r   i s   n o t   p a u s e d   t h i s   D e b u g g e r . O b j e c t   w r a p s   t h e   s c o p e   f o r   a u t o c o m p l e t i o n .   
   *                 I t   i s   n u l l   i f   t h e   d e b u g g e r   i s   p a u s e d .   
   *   @ p a r a m   o b j e c t   a n E n v i r o n m e n t   
   *                 W h e n   t h e   d e b u g g e r   i s   p a u s e d   t h i s   D e b u g g e r . E n v i r o n m e n t   i s   t h e   s c o p e   f o r   a u t o c o m p l e t i o n .   
   *                 I t   i s   n u l l   i f   t h e   d e b u g g e r   i s   n o t   p a u s e d .   
   *   @ p a r a m   s t r i n g   a I n p u t V a l u e   
   *                 V a l u e   t h a t   s h o u l d   b e   c o m p l e t e d .   
   *   @ p a r a m   n u m b e r   [ a C u r s o r = a I n p u t V a l u e . l e n g t h ]   
   *                 O p t i o n a l   o f f s e t   i n   t h e   i n p u t   w h e r e   t h e   c u r s o r   i s   l o c a t e d .   I f   t h i s   i s   
   *                 o m i t t e d   t h e n   t h e   c u r s o r   i s   a s s u m e d   t o   b e   a t   t h e   e n d   o f   t h e   i n p u t   
   *                 v a l u e .   
   *   @ r e t u r n s   n u l l   o r   o b j e c t   
   *                     I f   n o   c o m p l e t i o n   v a l u e d   c o u l d   b e   c o m p u t e d ,   n u l l   i s   r e t u r n e d ,   
   *                     o t h e r w i s e   a   o b j e c t   w i t h   t h e   f o l l o w i n g   f o r m   i s   r e t u r n e d :   
   *                         {   
   *                             m a t c h e s :   [   s t r i n g ,   s t r i n g ,   s t r i n g   ] ,   
   *                             m a t c h P r o p :   L a s t   p a r t   o f   t h e   i n p u t V a l u e   t h a t   w a s   u s e d   t o   f i n d   
   *                                                   t h e   m a t c h e s - s t r i n g s .   
   *                         }   
   * /   
 e x p o r t   f u n c t i o n   J S P r o p e r t y P r o v i d e r ( a D b g O b j e c t ,   a n E n v i r o n m e n t ,   a I n p u t V a l u e ,   a C u r s o r )   {   
         i f   ( a C u r s o r   = = =   u n d e f i n e d )   {   
                 a C u r s o r   =   a I n p u t V a l u e . l e n g t h ;   
         }   
   
         l e t   i n p u t V a l u e   =   a I n p u t V a l u e . s u b s t r i n g ( 0 ,   a C u r s o r ) ;   
   
         / /   A n a l y s e   t h e   i n p u t V a l u e   a n d   f i n d   t h e   b e g i n n i n g   o f   t h e   l a s t   p a r t   t h a t   
         / /   s h o u l d   b e   c o m p l e t e d .   
         l e t   b e g i n n i n g   =   f i n d C o m p l e t i o n B e g i n n i n g ( i n p u t V a l u e ) ;   
   
         / /   T h e r e   w a s   a n   e r r o r   a n a l y s i n g   t h e   s t r i n g .   
         i f   ( b e g i n n i n g . e r r )   {   
                 r e t u r n   n u l l ;   
         }   
   
         / /   I f   t h e   c u r r e n t   s t a t e   i s   n o t   S T A T E _ N O R M A L ,   t h e n   w e   a r e   i n s i d e   o f   a n   s t r i n g   
         / /   w h i c h   m e a n s   t h a t   n o   c o m p l e t i o n   i s   p o s s i b l e .   
         i f   ( b e g i n n i n g . s t a t e   ! =   S T A T E _ N O R M A L )   {   
                 r e t u r n   n u l l ;   
         }   
   
         l e t   c o m p l e t i o n P a r t   =   i n p u t V a l u e . s u b s t r i n g ( b e g i n n i n g . s t a r t P o s ) ;   
         l e t   l a s t D o t   =   c o m p l e t i o n P a r t . l a s t I n d e x O f ( " . " ) ;   
   
         / /   D o n ' t   c o m p l e t e   o n   j u s t   a n   e m p t y   s t r i n g .   
         i f   ( c o m p l e t i o n P a r t . t r i m ( )   = =   " " )   {   
                 r e t u r n   n u l l ;   
         }   
   
         / /   C a t c h   l i t e r a l s   l i k e   [ 1 , 2 , 3 ]   o r   " f o o "   a n d   r e t u r n   t h e   m a t c h e s   f r o m   
         / /   t h e i r   p r o t o t y p e s .   
         / /   D o n ' t   r u n   t h i s   i s   a   w o r k e r ,   m i g r a t i n g   t o   a c o r n   s h o u l d   a l l o w   t h i s   
         / /   t o   r u n   i n   a   w o r k e r   -   B u g   1 2 1 7 1 9 8 .   
         / / t o d o   
         / * i f   ( ! i s W o r k e r   & &   l a s t D o t   >   0 )   {   
           l e t   p a r s e r   =   n e w   P a r s e r ( ) ;   
           p a r s e r . l o g E x c e p t i o n s   =   f a l s e ;   
           l e t   s y n t a x T r e e   =   p a r s e r . g e t ( c o m p l e t i o n P a r t . s l i c e ( 0 ,   l a s t D o t ) ) ;   
           l e t   l a s t T r e e   =   s y n t a x T r e e . g e t L a s t S y n t a x T r e e ( ) ;   
           l e t   l a s t B o d y   =   l a s t T r e e   & &   l a s t T r e e . A S T . b o d y [ l a s t T r e e . A S T . b o d y . l e n g t h   -   1 ] ;   
   
           / /   F i n d i n g   t h e   l a s t   e x p r e s s i o n   s i n c e   w e ' v e   s l i c e d   u p   u n t i l   t h e   d o t .   
           / /   I f   t h e r e   w e r e   p a r s e   e r r o r s   t h i s   w o n ' t   e x i s t .   
           i f   ( l a s t B o d y )   {   
           l e t   e x p r e s s i o n   =   l a s t B o d y . e x p r e s s i o n ;   
           l e t   m a t c h P r o p   =   c o m p l e t i o n P a r t . s l i c e ( l a s t D o t   +   1 ) ;   
           i f   ( e x p r e s s i o n . t y p e   = = =   " A r r a y E x p r e s s i o n " )   {   
           r e t u r n   g e t M a t c h e d P r o p s ( A r r a y . p r o t o t y p e ,   m a t c h P r o p ) ;   
           }   e l s e   i f   ( e x p r e s s i o n . t y p e   = = =   " L i t e r a l "   & &   
           ( t y p e o f   e x p r e s s i o n . v a l u e   = = =   " s t r i n g " ) )   {   
           r e t u r n   g e t M a t c h e d P r o p s ( S t r i n g . p r o t o t y p e ,   m a t c h P r o p ) ;   
           }   
           }   
         } * /   
   
         / /   W e   a r e   c o m p l e t i n g   a   v a r i a b l e   /   a   p r o p e r t y   l o o k u p .   
         l e t   p r o p e r t i e s   =   c o m p l e t i o n P a r t . s p l i t ( " . " ) ;   
         l e t   m a t c h P r o p   =   p r o p e r t i e s . p o p ( ) . t r i m L e f t ( ) ;   
         l e t   o b j   =   a D b g O b j e c t ;   
   
         / /   T h e   f i r s t   p r o p e r t y   m u s t   b e   f o u n d   i n   t h e   e n v i r o n m e n t   o f   t h e   p a u s e d   d e b u g g e r   
         / /   o r   o f   t h e   g l o b a l   l e x i c a l   s c o p e .   
         l e t   e n v   =   a n E n v i r o n m e n t   | |   o b j . a s E n v i r o n m e n t ( ) ;   
   
         i f   ( p r o p e r t i e s . l e n g t h   = = =   0 )   {   
                 r e t u r n   g e t M a t c h e d P r o p s I n E n v i r o n m e n t ( e n v ,   m a t c h P r o p ) ;   
         }   
   
         l e t   f i r s t P r o p   =   p r o p e r t i e s . s h i f t ( ) . t r i m ( ) ;   
         i f   ( f i r s t P r o p   = = =   " t h i s " )   {   
                 / /   S p e c i a l   c a s e   f o r   ' t h i s '   -   t r y   t o   g e t   t h e   O b j e c t   f r o m   t h e   E n v i r o n m e n t .   
                 / /   N o   p r o b l e m   i f   i t   t h r o w s ,   w e   w i l l   j u s t   n o t   a u t o c o m p l e t e .   
                 t r y   {   
                         o b j   =   e n v . o b j e c t ;   
                 }   c a t c h   ( e )   {   
                 }   
         }   
         e l s e   i f   ( h a s A r r a y I n d e x ( f i r s t P r o p ) )   {   
                 o b j   =   g e t A r r a y M e m b e r P r o p e r t y ( n u l l ,   e n v ,   f i r s t P r o p ) ;   
         }   e l s e   {   
                 o b j   =   g e t V a r i a b l e I n E n v i r o n m e n t ( e n v ,   f i r s t P r o p ) ;   
         }   
   
         i f   ( ! i s O b j e c t U s a b l e ( o b j ) )   {   
                 r e t u r n   n u l l ;   
         }   
   
         / /   W e   g e t   t h e   r e s t   o f   t h e   p r o p e r t i e s   r e c u r s i v e l y   s t a r t i n g   f r o m   t h e   D e b u g g e r . O b j e c t   
         / /   t h a t   w r a p s   t h e   f i r s t   p r o p e r t y   
         f o r   ( l e t   i   =   0 ;   i   <   p r o p e r t i e s . l e n g t h ;   i + + )   {   
                 l e t   p r o p   =   p r o p e r t i e s [ i ] . t r i m ( ) ;   
                 i f   ( ! p r o p )   {   
                         r e t u r n   n u l l ;   
                 }   
   
                 i f   ( h a s A r r a y I n d e x ( p r o p ) )   {   
                         / /   T h e   p r o p e r t y   t o   a u t o c o m p l e t e   i s   a   m e m b e r   o f   a r r a y .   F o r   e x a m p l e   
                         / /   l i s t [ i ] [ j ] . . [ n ] .   T r a v e r s e   t h e   a r r a y   t o   g e t   t h e   a c t u a l   e l e m e n t .   
                         o b j   =   g e t A r r a y M e m b e r P r o p e r t y ( o b j ,   n u l l ,   p r o p ) ;   
                 }   
                 e l s e   {   
                         o b j   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( o b j ,   p r o p ) ;   
                 }   
   
                 i f   ( ! i s O b j e c t U s a b l e ( o b j ) )   {   
                         r e t u r n   n u l l ;   
                 }   
         }   
   
         / /   I f   t h e   f i n a l   p r o p e r t y   i s   a   p r i m i t i v e   
         i f   ( t y p e o f   o b j   ! =   " o b j e c t " )   {   
                 r e t u r n   g e t M a t c h e d P r o p s ( o b j ,   m a t c h P r o p ) ;   
         }   
   
         r e t u r n   g e t M a t c h e d P r o p s I n D b g O b j e c t ( o b j ,   m a t c h P r o p ) ;   
 }   
   
 / * *   
   *   G e t   t h e   a r r a y   m e m b e r   o f   a O b j   f o r   t h e   g i v e n   a P r o p .   F o r   e x a m p l e ,   g i v e n   
   *   a P r o p = ' l i s t [ 0 ] [ 1 ] '   t h e   e l e m e n t   a t   [ 0 ] [ 1 ]   o f   a O b j . l i s t   i s   r e t u r n e d .   
   *   
   *   @ p a r a m   o b j e c t   a O b j   
   *                 T h e   o b j e c t   t o   o p e r a t e   o n .   S h o u l d   b e   n u l l   i f   a E n v   i s   p a s s e d .   
   *   @ p a r a m   o b j e c t   a E n v   
   *                 T h e   E n v i r o n m e n t   t o   o p e r a t e   i n .   S h o u l d   b e   n u l l   i f   a O b j   i s   p a s s e d .   
   *   @ p a r a m   s t r i n g   a P r o p   
   *                 T h e   p r o p e r t y   t o   r e t u r n .   
   *   @ r e t u r n   n u l l   o r   O b j e c t   
   *                   R e t u r n s   n u l l   i f   t h e   p r o p e r t y   c o u l d n ' t   b e   l o c a t e d .   O t h e r w i s e   t h e   a r r a y   
   *                   m e m b e r   i d e n t i f i e d   b y   a P r o p .   
   * /   
 f u n c t i o n   g e t A r r a y M e m b e r P r o p e r t y ( a O b j ,   a E n v ,   a P r o p )   {   
         / /   F i r s t   g e t   t h e   a r r a y .   
         l e t   o b j   =   a O b j ;   
         l e t   p r o p W i t h o u t I n d i c e s   =   a P r o p . s u b s t r ( 0 ,   a P r o p . i n d e x O f ( " [ " ) ) ;   
   
         i f   ( a E n v )   {   
                 o b j   =   g e t V a r i a b l e I n E n v i r o n m e n t ( a E n v ,   p r o p W i t h o u t I n d i c e s ) ;   
         }   e l s e   {   
                 o b j   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( o b j ,   p r o p W i t h o u t I n d i c e s ) ;   
         }   
   
         i f   ( ! i s O b j e c t U s a b l e ( o b j ) )   {   
                 r e t u r n   n u l l ;   
         }   
   
         / /   T h e n   t r a v e r s e   t h e   l i s t   o f   i n d i c e s   t o   g e t   t h e   a c t u a l   e l e m e n t .   
         l e t   r e s u l t ;   
         l e t   a r r a y I n d i c e s R e g e x   =   / \ [ [ ^ \ ] ] * \ ] / g ;   
         w h i l e   ( ( r e s u l t   =   a r r a y I n d i c e s R e g e x . e x e c ( a P r o p ) )   ! = =   n u l l )   {   
                 l e t   i n d e x W i t h B r a c k e t s   =   r e s u l t [ 0 ] ;   
                 l e t   i n d e x A s T e x t   =   i n d e x W i t h B r a c k e t s . s u b s t r ( 1 ,   i n d e x W i t h B r a c k e t s . l e n g t h   -   2 ) ;   
                 l e t   i n d e x   =   p a r s e I n t ( i n d e x A s T e x t ) ;   
   
                 i f   ( i s N a N ( i n d e x ) )   {   
                         r e t u r n   n u l l ;   
                 }   
   
                 o b j   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( o b j ,   i n d e x ) ;   
   
                 i f   ( ! i s O b j e c t U s a b l e ( o b j ) )   {   
                         r e t u r n   n u l l ;   
                 }   
         }   
   
         r e t u r n   o b j ;   
 }   
   
 / * *   
   *   C h e c k   i f   t h e   g i v e n   D e b u g g e r . O b j e c t   c a n   b e   u s e d   f o r   a u t o c o m p l e t e .   
   *   
   *   @ p a r a m   D e b u g g e r . O b j e c t   a O b j e c t   
   *                 T h e   D e b u g g e r . O b j e c t   t o   c h e c k .   
   *   @ r e t u r n   b o o l e a n   
   *                   T r u e   i f   f u r t h e r   i n s p e c t i o n   i n t o   t h e   o b j e c t   i s   p o s s i b l e ,   o r   f a l s e   
   *                   o t h e r w i s e .   
   * /   
 f u n c t i o n   i s O b j e c t U s a b l e ( a O b j e c t )   {   
         i f   ( a O b j e c t   = =   n u l l )   {   
                 r e t u r n   f a l s e ;   
         }   
   
         i f   ( t y p e o f   a O b j e c t   = =   " o b j e c t "   & &   a O b j e c t . c l a s s   = =   " D e a d O b j e c t " )   {   
                 r e t u r n   f a l s e ;   
         }   
   
         r e t u r n   t r u e ;   
 }   
   
 / * *   
   *   @ s e e   g e t E x a c t M a t c h _ i m p l ( )   
   * /   
 f u n c t i o n   g e t V a r i a b l e I n E n v i r o n m e n t ( a n E n v i r o n m e n t ,   a N a m e )   {   
         r e t u r n   g e t E x a c t M a t c h _ i m p l ( a n E n v i r o n m e n t ,   a N a m e ,   D e b u g g e r E n v i r o n m e n t S u p p o r t ) ;   
 }   
   
 / * *   
   *   @ s e e   g e t M a t c h e d P r o p s _ i m p l ( )   
   * /   
 f u n c t i o n   g e t M a t c h e d P r o p s I n E n v i r o n m e n t ( a n E n v i r o n m e n t ,   a M a t c h )   {   
         r e t u r n   g e t M a t c h e d P r o p s _ i m p l ( a n E n v i r o n m e n t ,   a M a t c h ,   D e b u g g e r E n v i r o n m e n t S u p p o r t ) ;   
 }   
   
 / * *   
   *   @ s e e   g e t M a t c h e d P r o p s _ i m p l ( )   
   * /   
 f u n c t i o n   g e t M a t c h e d P r o p s I n D b g O b j e c t ( a D b g O b j e c t ,   a M a t c h )   {   
         r e t u r n   g e t M a t c h e d P r o p s _ i m p l ( a D b g O b j e c t ,   a M a t c h ,   D e b u g g e r O b j e c t S u p p o r t ) ;   
 }   
   
 / * *   
   *   @ s e e   g e t M a t c h e d P r o p s _ i m p l ( )   
   * /   
 f u n c t i o n   g e t M a t c h e d P r o p s ( a O b j ,   a M a t c h )   {   
         i f   ( t y p e o f   a O b j   ! =   " o b j e c t " )   {   
                 a O b j   =   a O b j . c o n s t r u c t o r . p r o t o t y p e ;   
         }   
         r e t u r n   g e t M a t c h e d P r o p s _ i m p l ( a O b j ,   a M a t c h ,   J S O b j e c t S u p p o r t ) ;   
 }   
   
 / * *   
   *   G e t   a l l   p r o p e r t i e s   i n   t h e   g i v e n   o b j e c t   ( a n d   i t s   p a r e n t   p r o t o t y p e   c h a i n )   t h a t   
   *   m a t c h   a   g i v e n   p r e f i x .   
   *   
   *   @ p a r a m   m i x e d   a O b j   
   *                 O b j e c t   w h o s e   p r o p e r t i e s   w e   w a n t   t o   f i l t e r .   
   *   @ p a r a m   s t r i n g   a M a t c h   
   *                 F i l t e r   f o r   p r o p e r t i e s   t h a t   m a t c h   t h i s   s t r i n g .   
   *   @ r e t u r n   o b j e c t   
   *                   O b j e c t   t h a t   c o n t a i n s   t h e   m a t c h P r o p   a n d   t h e   l i s t   o f   n a m e s .   
   * /   
 f u n c t i o n   g e t M a t c h e d P r o p s _ i m p l ( a O b j ,   a M a t c h ,   { c h a i n I t e r a t o r ,   g e t P r o p e r t i e s } )   {   
         l e t   m a t c h e s   =   n e w   S e t ( ) ;   
         l e t   n u m P r o p s   =   0 ;   
   
         / /   W e   n e e d   t o   g o   u p   t h e   p r o t o t y p e   c h a i n .   
         l e t   i t e r   =   c h a i n I t e r a t o r ( a O b j ) ;   
         f o r   ( l e t   o b j   o f   i t e r )   {   
                 l e t   p r o p s   =   g e t P r o p e r t i e s ( o b j ) ;   
                 n u m P r o p s   + =   p r o p s . l e n g t h ;   
   
                 / /   I f   t h e r e   a r e   t o o   m a n y   p r o p e r t i e s   t o   e v e n t   a t t e m p t   a u t o c o m p l e t i o n ,   
                 / /   o r   i f   w e   h a v e   a l r e a d y   a d d e d   t h e   m a x   n u m b e r ,   t h e n   s t o p   l o o p i n g   
                 / /   a n d   r e t u r n   t h e   p a r t i a l   s e t   t h a t   h a s   a l r e a d y   b e e n   d i s c o v e r e d .   
                 i f   ( n u m P r o p s   > =   M A X _ A U T O C O M P L E T E _ A T T E M P T S   | |   
                         m a t c h e s . s i z e   > =   M A X _ A U T O C O M P L E T I O N S )   {   
                         b r e a k ;   
                 }   
   
                 f o r   ( l e t   i   =   0 ;   i   <   p r o p s . l e n g t h ;   i + + )   {   
                         l e t   p r o p   =   p r o p s [ i ] ;   
                         i f   ( p r o p . i n d e x O f ( a M a t c h )   ! =   0 )   {   
                                 c o n t i n u e ;   
                         }   
                         i f   ( p r o p . i n d e x O f ( ' - ' )   >   - 1 )   {   
                                 c o n t i n u e ;   
                         }   
                         / /   I f   i t   i s   a n   a r r a y   i n d e x ,   w e   c a n ' t   t a k e   i t .   
                         / /   T h i s   u s e s   a   t r i c k :   c o n v e r t i n g   a   s t r i n g   t o   a   n u m b e r   y i e l d s   N a N   i f   
                         / /   t h e   o p e r a t i o n   f a i l e d ,   a n d   N a N   i s   n o t   e q u a l   t o   i t s e l f .   
                         i f   ( + p r o p   ! =   + p r o p )   {   
                                 m a t c h e s . a d d ( p r o p ) ;   
                         }   
   
                         i f   ( m a t c h e s . s i z e   > =   M A X _ A U T O C O M P L E T I O N S )   {   
                                 b r e a k ;   
                         }   
                 }   
         }   
   
         r e t u r n   {   
                 m a t c h P r o p :   a M a t c h ,   
                 m a t c h e s :   [ . . . m a t c h e s ] ,   
         } ;   
 }   
   
 / * *   
   *   R e t u r n s   a   p r o p e r t y   v a l u e   b a s e d   o n   i t s   n a m e   f r o m   t h e   g i v e n   o b j e c t ,   b y   
   *   r e c u r s i v e l y   c h e c k i n g   t h e   o b j e c t ' s   p r o t o t y p e .   
   *   
   *   @ p a r a m   o b j e c t   a O b j   
   *                 A n   o b j e c t   t o   l o o k   t h e   p r o p e r t y   i n t o .   
   *   @ p a r a m   s t r i n g   a N a m e   
   *                 T h e   p r o p e r t y   t h a t   i s   l o o k e d   u p .   
   *   @ r e t u r n s   o b j e c t | u n d e f i n e d   
   *                 A   D e b u g g e r . O b j e c t   i f   t h e   p r o p e r t y   e x i s t s   i n   t h e   o b j e c t ' s   p r o t o t y p e   
   *                 c h a i n ,   u n d e f i n e d   o t h e r w i s e .   
   * /   
 f u n c t i o n   g e t E x a c t M a t c h _ i m p l ( a O b j ,   a N a m e ,   { c h a i n I t e r a t o r ,   g e t P r o p e r t y } )   {   
         / /   W e   n e e d   t o   g o   u p   t h e   p r o t o t y p e   c h a i n .   
         l e t   i t e r   =   c h a i n I t e r a t o r ( a O b j ) ;   
         f o r   ( l e t   o b j   o f   i t e r )   {   
                 l e t   p r o p   =   g e t P r o p e r t y ( o b j ,   a N a m e ,   a O b j ) ;   
                 i f   ( p r o p )   {   
                         r e t u r n   p r o p . v a l u e ;   
                 }   
         }   
         r e t u r n   u n d e f i n e d ;   
 }   
   
   
 v a r   J S O b j e c t S u p p o r t   =   {   
         c h a i n I t e r a t o r :   f u n c t i o n * ( a O b j )   {   
                 w h i l e   ( a O b j )   {   
                         y i e l d   a O b j ;   
                         a O b j   =   O b j e c t . g e t P r o t o t y p e O f ( a O b j ) ;   
                 }   
         } ,   
   
         g e t P r o p e r t i e s :   f u n c t i o n   ( a O b j )   {   
                 r e t u r n   O b j e c t . g e t O w n P r o p e r t y N a m e s ( a O b j ) ;   
         } ,   
   
         g e t P r o p e r t y :   f u n c t i o n   ( )   {   
                 / /   g e t P r o p e r t y   i s   u n s a f e   w i t h   r a w   J S   o b j e c t s .   
                 t h r o w   " U n i m p l e m e n t e d ! " ;   
         } ,   
 } ;   
   
 v a r   D e b u g g e r O b j e c t S u p p o r t   =   {   
         c h a i n I t e r a t o r :   f u n c t i o n * ( a O b j )   {   
                 w h i l e   ( a O b j )   {   
                         y i e l d   a O b j ;   
                         a O b j   =   a O b j . p r o t o ;   
                 }   
         } ,   
   
         g e t P r o p e r t i e s :   f u n c t i o n   ( a O b j )   {   
                 r e t u r n   a O b j . g e t O w n P r o p e r t y N a m e s ( ) ;   
         } ,   
   
         g e t P r o p e r t y :   f u n c t i o n   ( a O b j ,   a N a m e ,   a R o o t O b j )   {   
                 / /   T h i s   i s   l e f t   u n i m p l e m e n t e d   i n   f a v o r   t o   D e v T o o l s U t i l s . g e t P r o p e r t y ( ) .   
                 t h r o w   " U n i m p l e m e n t e d ! " ;   
         } ,   
 } ;   
   
 v a r   D e b u g g e r E n v i r o n m e n t S u p p o r t   =   {   
         c h a i n I t e r a t o r :   f u n c t i o n * ( a O b j )   {   
                 w h i l e   ( a O b j )   {   
                         y i e l d   a O b j ;   
                         a O b j   =   a O b j . p a r e n t ;   
                 }   
         } ,   
   
         g e t P r o p e r t i e s :   f u n c t i o n   ( a O b j )   {   
                 l e t   n a m e s   =   a O b j . n a m e s ( ) ;   
   
                 / /   I n c l u d e   ' t h i s '   i n   r e s u l t s   ( i n   s o r t e d   o r d e r )   
                 f o r   ( l e t   i   =   0 ;   i   <   n a m e s . l e n g t h ;   i + + )   {   
                         i f   ( i   = = =   n a m e s . l e n g t h   -   1   | |   n a m e s [ i   +   1 ]   >   " t h i s " )   {   
                                 n a m e s . s p l i c e ( i   +   1 ,   0 ,   " t h i s " ) ;   
                                 b r e a k ;   
                         }   
                 }   
   
                 r e t u r n   n a m e s ;   
         } ,   
   
         g e t P r o p e r t y :   f u n c t i o n   ( a O b j ,   a N a m e )   {   
                 l e t   r e s u l t ;   
                 / /   T r y / c a t c h   s i n c e   a N a m e   c a n   b e   a n y t h i n g ,   a n d   g e t V a r i a b l e   t h r o w s   i f   
                 / /   i t ' s   n o t   a   v a l i d   E C M A S c r i p t   i d e n t i f i e r   n a m e   
                 t r y   {   
                         / /   T O D O :   w e   s h o u l d   u s e   g e t V a r i a b l e D e s c r i p t o r ( )   h e r e   -   b u g   7 2 5 8 1 5 .   
                         r e s u l t   =   a O b j . g e t V a r i a b l e ( a N a m e ) ;   
                 }   c a t c h   ( e )   {   
                 }   
   
                 / /   F I X M E :   N e e d   a c t u a l   U I ,   b u g   9 4 1 2 8 7 .   
                 i f   ( r e s u l t   = = =   u n d e f i n e d   | |   r e s u l t . o p t i m i z e d O u t   | |   r e s u l t . m i s s i n g A r g u m e n t s )   {   
                         r e t u r n   n u l l ;   
                 }   
                 r e t u r n   { v a l u e :   r e s u l t } ;   
         }   
 } ;   
 0�  `   ��
 D E V T O O L S / O B J E C T A C T O R P R E V I E W E R S . J S       0	        i m p o r t   *   a s   D e v T o o l s U t i l s   f r o m   ' D e v T o o l s / D e v T o o l s U t i l s . j s ' ;   
 l e t   { g l o b a l }   =   p r o c e s s . b i n d i n g ( ' d e b u g g e r ' ) ;   
   
 c o n s t   T Y P E D _ A R R A Y _ C L A S S E S   =   [ " U i n t 8 A r r a y " ,   " U i n t 8 C l a m p e d A r r a y " ,   " U i n t 1 6 A r r a y " ,   
         " U i n t 3 2 A r r a y " ,   " I n t 8 A r r a y " ,   " I n t 1 6 A r r a y " ,   " I n t 3 2 A r r a y " ,   " F l o a t 3 2 A r r a y " ,   
         " F l o a t 6 4 A r r a y " ] ;   
   
   
 / /   N u m b e r   o f   i t e m s   t o   p r e v i e w   i n   o b j e c t s ,   a r r a y s ,   m a p s ,   s e t s ,   l i s t s ,   
 / /   c o l l e c t i o n s ,   e t c .   
 c o n s t   O B J E C T _ P R E V I E W _ M A X _ I T E M S   =   1 0 ;   
   
 l e t   _ O b j e c t A c t o r P r e v i e w e r s   =   {   
         S t r i n g :   [ f u n c t i o n   ( o b j e c t A c t o r ,   g r i p )   {   
                 r e t u r n   w r a p p e d P r i m i t i v e P r e v i e w e r ( " S t r i n g " ,   S t r i n g ,   o b j e c t A c t o r ,   g r i p ) ;   
         } ] ,   
   
         B o o l e a n :   [ f u n c t i o n   ( o b j e c t A c t o r ,   g r i p )   {   
                 r e t u r n   w r a p p e d P r i m i t i v e P r e v i e w e r ( " B o o l e a n " ,   B o o l e a n ,   o b j e c t A c t o r ,   g r i p ) ;   
         } ] ,   
   
         N u m b e r :   [ f u n c t i o n   ( o b j e c t A c t o r ,   g r i p )   {   
                 r e t u r n   w r a p p e d P r i m i t i v e P r e v i e w e r ( " N u m b e r " ,   N u m b e r ,   o b j e c t A c t o r ,   g r i p ) ;   
         } ] ,   
   
         F u n c t i o n :   [ f u n c t i o n   ( o b j e c t A c t o r ,   g r i p )   {   
                 l e t   { _ o b j }   =   o b j e c t A c t o r ;   
                 i f   ( _ o b j . n a m e )   {   
                         g r i p . n a m e   =   _ o b j . n a m e ;   
                 }   
   
                 i f   ( _ o b j . d i s p l a y N a m e )   {   
                         g r i p . d i s p l a y N a m e   =   _ o b j . d i s p l a y N a m e . s u b s t r ( 0 ,   5 0 0 ) ;   
                 }   
   
                 i f   ( _ o b j . p a r a m e t e r N a m e s )   {   
                         g r i p . p a r a m e t e r N a m e s   =   _ o b j . p a r a m e t e r N a m e s ;   
                 }   
   
                 / /   C h e c k   i f   t h e   d e v e l o p e r   h a s   a d d e d   a   d e - f a c t o   s t a n d a r d   d i s p l a y N a m e   
                 / /   p r o p e r t y   f o r   u s   t o   u s e .   
                 l e t   u s e r D i s p l a y N a m e ;   
                 t r y   {   
                         u s e r D i s p l a y N a m e   =   _ o b j . g e t O w n P r o p e r t y D e s c r i p t o r ( " d i s p l a y N a m e " ) ;   
                 }   c a t c h   ( e )   {   
                         / /   C a l l i n g   g e t O w n P r o p e r t y D e s c r i p t o r   w i t h   d i s p l a y N a m e   m i g h t   t h r o w   
                         / /   w i t h   " p e r m i s s i o n   d e n i e d "   e r r o r s   f o r   s o m e   f u n c t i o n s .   
                         / / d u m p n ( e ) ;   
                 }   
   
                 i f   ( u s e r D i s p l a y N a m e   & &   t y p e o f   u s e r D i s p l a y N a m e . v a l u e   = =   " s t r i n g "   & &   
                         u s e r D i s p l a y N a m e . v a l u e )   {   
                         g r i p . u s e r D i s p l a y N a m e   =   o b j e c t A c t o r . g e t G r i p ( u s e r D i s p l a y N a m e . v a l u e ) ;   
                 }   
   
                 / / l e t   d b g G l o b a l   =   h o o k s . g e t G l o b a l D e b u g O b j e c t ( ) ;   
                 / / i f   ( d b g G l o b a l )   {   
                 / / l e t   s c r i p t   =   d b g G l o b a l . m a k e D e b u g g e e V a l u e ( _ o b j . u n s a f e D e r e f e r e n c e ( ) ) . s c r i p t ;   
                 l e t   s c r i p t   =   _ o b j . s c r i p t ;   
                 i f   ( s c r i p t )   {   
                         g r i p . l o c a t i o n   =   {   
                                 u r l :   s c r i p t . u r l ,   
                                 l i n e :   s c r i p t . s t a r t L i n e   
                         } ;   
                 }   
                 / / }   
   
                 r e t u r n   t r u e ;   
         } ] ,   
   
         R e g E x p :   [ f u n c t i o n   ( o b j e c t A c t o r ,   g r i p )   {   
                 l e t   { _ o b j }   =   o b j e c t A c t o r ;   
                 / /   A v o i d   h a v i n g   a n y   s p e c i a l   p r e v i e w   f o r   t h e   R e g E x p . p r o t o t y p e   i t s e l f .   
                 i f   ( ! _ o b j . p r o t o   | |   _ o b j . p r o t o . c l a s s   ! =   " R e g E x p " )   {   
                         r e t u r n   f a l s e ;   
                 }   
   
                 l e t   s t r   =   R e g E x p . p r o t o t y p e . t o S t r i n g . c a l l ( _ o b j . u n s a f e D e r e f e r e n c e ( ) ) ;   
                 g r i p . d i s p l a y S t r i n g   =   o b j e c t A c t o r . g e t G r i p ( s t r ) ;   
                 r e t u r n   t r u e ;   
         } ] ,   
   
         D a t e :   [ f u n c t i o n   ( o b j e c t A c t o r ,   g r i p )   {   
                 l e t   { _ o b j }   =   o b j e c t A c t o r ;   
                 l e t   t i m e   =   D a t e . p r o t o t y p e . g e t T i m e . c a l l ( _ o b j . u n s a f e D e r e f e r e n c e ( ) ) ;   
   
                 g r i p . p r e v i e w   =   {   
                         t i m e s t a m p :   o b j e c t A c t o r . g e t G r i p ( t i m e )   
                 } ;   
                 r e t u r n   t r u e ;   
         } ] ,   
   
         A r r a y :   [ f u n c t i o n   ( o b j e c t A c t o r ,   g r i p )   {   
                 l e t   { _ o b j }   =   o b j e c t A c t o r ;   
                 l e t   l e n g t h   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " l e n g t h " ) ;   
                 i f   ( t y p e o f   l e n g t h   ! =   " n u m b e r " )   {   
                         r e t u r n   f a l s e ;   
                 }   
   
                 g r i p . p r e v i e w   =   {   
                         k i n d :   " A r r a y L i k e " ,   
                         l e n g t h :   l e n g t h   
                 } ;   
   
                 i f   ( o b j e c t A c t o r . g e t G r i p D e p t h ( )   >   1 )   {   
                         r e t u r n   t r u e ;   
                 }   
   
                 l e t   r a w   =   _ o b j . u n s a f e D e r e f e r e n c e ( ) ;   
                 l e t   i t e m s   =   g r i p . p r e v i e w . i t e m s   =   [ ] ;   
   
                 f o r   ( l e t   i   =   0 ;   i   <   l e n g t h ;   + + i )   {   
                         / /   A r r a y   X r a y s   f i l t e r   o u t   v a r i o u s   p o s s i b l y - u n s a f e   p r o p e r t i e s   ( l i k e   
                         / /   f u n c t i o n s ,   a n d   c l a i m   t h a t   t h e   v a l u e   i s   u n d e f i n e d   i n s t e a d .   T h i s   
                         / /   i s   g e n e r a l l y   t h e   r i g h t   t h i n g   f o r   p r i v i l e g e d   c o d e   a c c e s s i n g   u n t r u s t e d   
                         / /   o b j e c t s ,   b u t   q u i t e   c o n f u s i n g   f o r   O b j e c t   p r e v i e w s .   S o   w e   m a n u a l l y   
                         / /   o v e r r i d e   t h i s   p r o t e c t i o n   b y   w a i v i n g   X r a y s   o n   t h e   a r r a y ,   a n d   r e - a p p l y i n g   
                         / /   X r a y s   o n   a n y   i n d e x e d   v a l u e   p r o p s   t h a t   w e   p u l l   o f f   o f   i t .   
                         / / l e t   d e s c   =   O b j e c t . g e t O w n P r o p e r t y D e s c r i p t o r ( C u . w a i v e X r a y s ( r a w ) ,   i ) ;   
                         l e t   d e s c   =   O b j e c t . g e t O w n P r o p e r t y D e s c r i p t o r ( r a w ,   i ) ;   
                         i f   ( d e s c   & &   ! d e s c . g e t   & &   ! d e s c . s e t )   {   
                                 / / l e t   v a l u e   =   C u . u n w a i v e X r a y s ( d e s c . v a l u e ) ;   
                                 l e t   v a l u e   =   d e s c . v a l u e ;   
                                 v a l u e   =   m a k e D e b u g g e e V a l u e I f N e e d e d ( _ o b j ,   v a l u e ) ;   
                                 i t e m s . p u s h ( o b j e c t A c t o r . g e t G r i p ( v a l u e ) ) ;   
                         }   e l s e   {   
                                 i t e m s . p u s h ( n u l l ) ;   
                         }   
   
                         i f   ( i t e m s . l e n g t h   = =   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
                                 b r e a k ;   
                         }   
                 }   
   
                 r e t u r n   t r u e ;   
         } ] ,   
   
         S e t :   [ f u n c t i o n   ( o b j e c t A c t o r ,   g r i p )   {   
                 l e t   { _ o b j }   =   o b j e c t A c t o r ;   
                 l e t   s i z e   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " s i z e " ) ;   
                 i f   ( t y p e o f   s i z e   ! =   " n u m b e r " )   {   
                         r e t u r n   f a l s e ;   
                 }   
   
                 g r i p . p r e v i e w   =   {   
                         k i n d :   " A r r a y L i k e " ,   
                         l e n g t h :   s i z e   
                 } ;   
   
                 / /   A v o i d   r e c u r s i v e   o b j e c t   g r i p s .   
                 i f   ( o b j e c t A c t o r . g e t G r i p D e p t h ( )   >   1 )   {   
                         r e t u r n   t r u e ;   
                 }   
   
                 l e t   r a w   =   _ o b j . u n s a f e D e r e f e r e n c e ( ) ;   
                 l e t   i t e m s   =   g r i p . p r e v i e w . i t e m s   =   [ ] ;   
                 / /   W e   c u r r e n t l y   l a c k   X r a y W r a p p e r s   f o r   S e t ,   s o   w h e n   w e   i t e r a t e   o v e r   
                 / /   t h e   v a l u e s ,   t h e   t e m p o r a r y   i t e r a t o r   o b j e c t s   g e t   c r e a t e d   i n   t h e   t a r g e t   
                 / /   c o m p a r t m e n t .   H o w e v e r ,   w e   _ d o _   h a v e   X r a y s   t o   O b j e c t   n o w ,   s o   w e   e n d   u p   
                 / /   X r a y i n g   t h o s e   t e m p o r a r y   o b j e c t s ,   a n d   f i l t e r i n g   a c c e s s   t o   | i t . v a l u e |   
                 / /   b a s e d   o n   w h e t h e r   o r   n o t   i t ' s   X r a y a b l e   a n d / o r   c a l l a b l e ,   w h i c h   b r e a k s   
                 / /   t h e   f o r / o f   i t e r a t i o n .   
                 / /   
                 / /   T h i s   c o d e   i s   d e s i g n e d   t o   h a n d l e   u n t r u s t e d   o b j e c t s ,   s o   w e   c a n   s a f e l y   
                 / /   w a i v e   X r a y s   o n   t h e   i t e r a b l e ,   a n d   r e l y i n g   o n   t h e   D e b u g g e r   m a c h i n e r y   t o   
                 / /   m a k e   s u r e   w e   h a n d l e   t h e   r e s u l t i n g   o b j e c t s   c a r e f u l l y .   
                 / / f o r   ( l e t   i t e m   o f   C u . w a i v e X r a y s ( S e t . p r o t o t y p e . v a l u e s . c a l l ( r a w ) ) )   {   
                 f o r   ( l e t   i t e m   o f   S e t . p r o t o t y p e . v a l u e s . c a l l ( r a w ) )   {   
                         / / i t e m   =   C u . u n w a i v e X r a y s ( i t e m ) ;   
                         i t e m   =   m a k e D e b u g g e e V a l u e I f N e e d e d ( _ o b j ,   i t e m ) ;   
                         i t e m s . p u s h ( o b j e c t A c t o r . g e t G r i p ( i t e m ) ) ;   
                         i f   ( i t e m s . l e n g t h   = =   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
                                 b r e a k ;   
                         }   
                 }   
   
                 r e t u r n   t r u e ;   
         } ] ,   
         / * W e a k S e t :   [ f u n c t i o n ( o b j e c t A c t o r ,   g r i p )   {   
           l e t   { _ o b j }   =   o b j e c t A c t o r ;   
           l e t   r a w   =   _ o b j . u n s a f e D e r e f e r e n c e ( ) ;   
   
           / /   W e   c u r r e n t l y   l a c k   X r a y W r a p p e r s   f o r   W e a k S e t ,   s o   w h e n   w e   i t e r a t e   o v e r   
           / /   t h e   v a l u e s ,   t h e   t e m p o r a r y   i t e r a t o r   o b j e c t s   g e t   c r e a t e d   i n   t h e   t a r g e t   
           / /   c o m p a r t m e n t .   H o w e v e r ,   w e   _ d o _   h a v e   X r a y s   t o   O b j e c t   n o w ,   s o   w e   e n d   u p   
           / /   X r a y i n g   t h o s e   t e m p o r a r y   o b j e c t s ,   a n d   f i l t e r i n g   a c c e s s   t o   | i t . v a l u e |   
           / /   b a s e d   o n   w h e t h e r   o r   n o t   i t ' s   X r a y a b l e   a n d / o r   c a l l a b l e ,   w h i c h   b r e a k s   
           / /   t h e   f o r / o f   i t e r a t i o n .   
           / /   
           / /   T h i s   c o d e   i s   d e s i g n e d   t o   h a n d l e   u n t r u s t e d   o b j e c t s ,   s o   w e   c a n   s a f e l y   
           / /   w a i v e   X r a y s   o n   t h e   i t e r a b l e ,   a n d   r e l y i n g   o n   t h e   D e b u g g e r   m a c h i n e r y   t o   
           / /   m a k e   s u r e   w e   h a n d l e   t h e   r e s u l t i n g   o b j e c t s   c a r e f u l l y .   
           / / l e t   k e y s   =   C u . w a i v e X r a y s ( T h r e a d S a f e C h r o m e U t i l s . n o n d e t e r m i n i s t i c G e t W e a k S e t K e y s ( r a w ) ) ;   
           l e t   k e y s   =   C u . w a i v e X r a y s ( T h r e a d S a f e C h r o m e U t i l s . n o n d e t e r m i n i s t i c G e t W e a k S e t K e y s ( r a w ) ) ;   
           g r i p . p r e v i e w   =   {   
           k i n d :   " A r r a y L i k e " ,   
           l e n g t h :   k e y s . l e n g t h   
           } ;   
   
           / / / /   A v o i d   r e c u r s i v e   o b j e c t   g r i p s .   
           / / i f   ( h o o k s . g e t G r i p D e p t h ( )   >   1 )   {   
           / / r e t u r n   t r u e ;   
           / / }   
   
           l e t   i t e m s   =   g r i p . p r e v i e w . i t e m s   =   [ ] ;   
           f o r   ( l e t   i t e m   o f   k e y s )   {   
           / / i t e m   =   C u . u n w a i v e X r a y s ( i t e m ) ;   
           i t e m   =   m a k e D e b u g g e e V a l u e I f N e e d e d ( o b j ,   i t e m ) ;   
           i t e m s . p u s h ( h o o k s . c r e a t e V a l u e G r i p ( i t e m ) ) ;   
           i f   ( i t e m s . l e n g t h   = =   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
           b r e a k ;   
           }   
           }   
   
           r e t u r n   t r u e ;   
           } ] , * /   
   
         M a p :   [ f u n c t i o n   ( o b j e c t A c t o r ,   g r i p )   {   
                 l e t   { _ o b j }   =   o b j e c t A c t o r ;   
                 l e t   s i z e   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " s i z e " ) ;   
                 i f   ( t y p e o f   s i z e   ! =   " n u m b e r " )   {   
                         r e t u r n   f a l s e ;   
                 }   
   
                 g r i p . p r e v i e w   =   {   
                         k i n d :   " M a p L i k e " ,   
                         s i z e :   s i z e   
                 } ;   
   
                 i f   ( o b j e c t A c t o r . g e t G r i p D e p t h ( )   >   1 )   {   
                         r e t u r n   t r u e ;   
                 }   
   
                 l e t   r a w   =   _ o b j . u n s a f e D e r e f e r e n c e ( ) ;   
                 l e t   e n t r i e s   =   g r i p . p r e v i e w . e n t r i e s   =   [ ] ;   
                 / /   I t e r a t i n g   o v e r   a   M a p   v i a   . e n t r i e s   g o e s   t h r o u g h   v a r i o u s   i n t e r m e d i a t e   
                 / /   o b j e c t s   -   a n   I t e r a t o r   o b j e c t ,   t h e n   a   2 - e l e m e n t   A r r a y   o b j e c t ,   t h e n   t h e   
                 / /   a c t u a l   v a l u e s   w e   c a r e   a b o u t .   W e   d o n ' t   h a v e   X r a y s   t o   I t e r a t o r   o b j e c t s ,   
                 / /   s o   w e   g e t   O p a q u e   w r a p p e r s   f o r   t h e m .   A n d   e v e n   t h o u g h   w e   h a v e   X r a y s   t o   
                 / /   A r r a y s ,   t h e   s e m a n t i c s   o f t e n   d e n y   a c c e s s   t o   t h e   e n t i r e s   b a s e d   o n   t h e   
                 / /   n a t u r e   o f   t h e   v a l u e s .   S o   w e   n e e d   w a i v e   X r a y s   f o r   t h e   i t e r a t o r   o b j e c t   
                 / /   a n d   t h e   t u p e s ,   a n d   t h e n   r e - a p p l y   t h e m   o n   t h e   u n d e r l y i n g   v a l u e s   u n t i l   
                 / /   w e   f i x   b u g   1 0 2 3 9 8 4 .   
                 / /   
                 / /   E v e n   t h e n   t h o u g h ,   w e   m i g h t   w a n t   t o   c o n t i n u e   w a i v i n g   X r a y s   h e r e   f o r   t h e   
                 / /   s a m e   r e a s o n   w e   d o   s o   f o r   A r r a y s   a b o v e   -   t h i s   f i l t e r i n g   b e h a v i o r   i s   l i k e l y   
                 / /   t o   b e   m o r e   c o n f u s i n g   t h a n   b e n e f i c i a l   i n   t h e   c a s e   o f   O b j e c t   p r e v i e w s .   
                 / / f o r   ( l e t   k e y V a l u e P a i r   o f   C u . w a i v e X r a y s ( M a p . p r o t o t y p e . e n t r i e s . c a l l ( r a w ) ) )   {   
                 f o r   ( l e t   k e y V a l u e P a i r   o f   M a p . p r o t o t y p e . e n t r i e s . c a l l ( r a w ) )   {   
                         / / l e t   k e y   =   C u . u n w a i v e X r a y s ( k e y V a l u e P a i r [ 0 ] ) ;   
                         l e t   k e y   =   k e y V a l u e P a i r [ 0 ] ;   
                         / / l e t   v a l u e   =   C u . u n w a i v e X r a y s ( k e y V a l u e P a i r [ 1 ] ) ;   
                         l e t   v a l u e   =   k e y V a l u e P a i r [ 1 ] ;   
                         k e y   =   m a k e D e b u g g e e V a l u e I f N e e d e d ( _ o b j ,   k e y ) ;   
                         v a l u e   =   m a k e D e b u g g e e V a l u e I f N e e d e d ( _ o b j ,   v a l u e ) ;   
                         e n t r i e s . p u s h ( [ o b j e c t A c t o r . g e t G r i p ( k e y ) ,   
                                 o b j e c t A c t o r . g e t G r i p ( v a l u e ) ] ) ;   
                         i f   ( e n t r i e s . l e n g t h   = =   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
                                 b r e a k ;   
                         }   
                 }   
   
                 r e t u r n   t r u e ;   
         } ] / * ,   
   
           W e a k M a p :   [ f u n c t i o n ( { o b j ,   h o o k s } ,   g r i p )   {   
           l e t   r a w   =   o b j . u n s a f e D e r e f e r e n c e ( ) ;   
           / /   W e   c u r r e n t l y   l a c k   X r a y W r a p p e r s   f o r   W e a k M a p ,   s o   w h e n   w e   i t e r a t e   o v e r   
           / /   t h e   v a l u e s ,   t h e   t e m p o r a r y   i t e r a t o r   o b j e c t s   g e t   c r e a t e d   i n   t h e   t a r g e t   
           / /   c o m p a r t m e n t .   H o w e v e r ,   w e   _ d o _   h a v e   X r a y s   t o   O b j e c t   n o w ,   s o   w e   e n d   u p   
           / /   X r a y i n g   t h o s e   t e m p o r a r y   o b j e c t s ,   a n d   f i l t e r i n g   a c c e s s   t o   | i t . v a l u e |   
           / /   b a s e d   o n   w h e t h e r   o r   n o t   i t ' s   X r a y a b l e   a n d / o r   c a l l a b l e ,   w h i c h   b r e a k s   
           / /   t h e   f o r / o f   i t e r a t i o n .   
           / /   
           / /   T h i s   c o d e   i s   d e s i g n e d   t o   h a n d l e   u n t r u s t e d   o b j e c t s ,   s o   w e   c a n   s a f e l y   
           / /   w a i v e   X r a y s   o n   t h e   i t e r a b l e ,   a n d   r e l y i n g   o n   t h e   D e b u g g e r   m a c h i n e r y   t o   
           / /   m a k e   s u r e   w e   h a n d l e   t h e   r e s u l t i n g   o b j e c t s   c a r e f u l l y .   
           l e t   r a w E n t r i e s   =   C u . w a i v e X r a y s ( T h r e a d S a f e C h r o m e U t i l s . n o n d e t e r m i n i s t i c G e t W e a k M a p K e y s ( r a w ) ) ;   
   
           g r i p . p r e v i e w   =   {   
           k i n d :   " M a p L i k e " ,   
           s i z e :   r a w E n t r i e s . l e n g t h ,   
           } ;   
   
           i f   ( h o o k s . g e t G r i p D e p t h ( )   >   1 )   {   
           r e t u r n   t r u e ;   
           }   
   
           l e t   e n t r i e s   =   g r i p . p r e v i e w . e n t r i e s   =   [ ] ;   
           f o r   ( l e t   k e y   o f   r a w E n t r i e s )   {   
           l e t   v a l u e   =   C u . u n w a i v e X r a y s ( W e a k M a p . p r o t o t y p e . g e t . c a l l ( r a w ,   k e y ) ) ;   
           k e y   =   C u . u n w a i v e X r a y s ( k e y ) ;   
           k e y   =   m a k e D e b u g g e e V a l u e I f N e e d e d ( o b j ,   k e y ) ;   
           v a l u e   =   m a k e D e b u g g e e V a l u e I f N e e d e d ( o b j ,   v a l u e ) ;   
           e n t r i e s . p u s h ( [ h o o k s . c r e a t e V a l u e G r i p ( k e y ) ,   
           h o o k s . c r e a t e V a l u e G r i p ( v a l u e ) ] ) ;   
           i f   ( e n t r i e s . l e n g t h   = =   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
           b r e a k ;   
           }   
           }   
   
           r e t u r n   t r u e ;   
           } ] ,   
   
           D O M S t r i n g M a p :   [ f u n c t i o n ( { o b j ,   h o o k s } ,   g r i p ,   r a w O b j )   {   
           i f   ( ! r a w O b j )   {   
           r e t u r n   f a l s e ;   
           }   
   
           l e t   k e y s   =   o b j . g e t O w n P r o p e r t y N a m e s ( ) ;   
           g r i p . p r e v i e w   =   {   
           k i n d :   " M a p L i k e " ,   
           s i z e :   k e y s . l e n g t h ,   
           } ;   
   
           i f   ( h o o k s . g e t G r i p D e p t h ( )   >   1 )   {   
           r e t u r n   t r u e ;   
           }   
   
           l e t   e n t r i e s   =   g r i p . p r e v i e w . e n t r i e s   =   [ ] ;   
           f o r   ( l e t   k e y   o f   k e y s )   {   
           l e t   v a l u e   =   m a k e D e b u g g e e V a l u e I f N e e d e d ( o b j ,   r a w O b j [ k e y ] ) ;   
           e n t r i e s . p u s h ( [ k e y ,   h o o k s . c r e a t e V a l u e G r i p ( v a l u e ) ] ) ;   
           i f   ( e n t r i e s . l e n g t h   = =   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
           b r e a k ;   
           }   
           }   
   
           r e t u r n   t r u e ;   
           } ] , * /   
 } ;   
   
 / * *   
   *   G e n e r i c   p r e v i e w e r   f o r   c l a s s e s   w r a p p i n g   p r i m i t i v e s ,   l i k e   S t r i n g ,   
   *   N u m b e r   a n d   B o o l e a n .   
   *   
   *   @ p a r a m   s t r i n g   c l a s s N a m e   
   *                 C l a s s   n a m e   t o   e x p e c t .   
   *   @ p a r a m   o b j e c t   c l a s s O b j   
   *                 T h e   c l a s s   t o   e x p e c t ,   e g .   S t r i n g .   T h e   v a l u e O f ( )   m e t h o d   o f   t h e   c l a s s   i s   
   *                 i n v o k e d   o n   t h e   g i v e n   o b j e c t .   
   *   @ p a r a m   O b j e c t A c t o r   o b j e c t A c t o r   
   *                 T h e   o b j e c t   a c t o r   
   *   @ p a r a m   O b j e c t   g r i p   
   *                 T h e   r e s u l t   g r i p   t o   f i l l   i n   
   *   @ r e t u r n   B o o o l e a n   t r u e   i f   t h e   o b j e c t   w a s   h a n d l e d ,   f a l s e   o t h e r w i s e   
   * /   
 f u n c t i o n   w r a p p e d P r i m i t i v e P r e v i e w e r ( c l a s s N a m e ,   c l a s s O b j ,   o b j e c t A c t o r ,   g r i p )   {   
         l e t   { _ o b j }   =   o b j e c t A c t o r ;   
   
         i f   ( ! _ o b j . p r o t o   | |   _ o b j . p r o t o . c l a s s   ! =   c l a s s N a m e )   {   
                 r e t u r n   f a l s e ;   
         }   
   
         l e t   r a w   =   _ o b j . u n s a f e D e r e f e r e n c e ( ) ;   
         l e t   v   =   n u l l ;   
         t r y   {   
                 v   =   c l a s s O b j . p r o t o t y p e . v a l u e O f . c a l l ( r a w ) ;   
         }   c a t c h   ( e x )   {   
                 / /   v a l u e O f ( )   c a n   t h r o w   i f   t h e   r a w   J S   o b j e c t   i s   " m i s b e h a v e d " .   
                 r e t u r n   f a l s e ;   
         }   
   
         i f   ( v   = = =   n u l l )   {   
                 r e t u r n   f a l s e ;   
         }   
   
         l e t   c a n H a n d l e   =   G e n e r i c O b j e c t ( o b j e c t A c t o r ,   g r i p ,   c l a s s N a m e   = = =   " S t r i n g " ) ;   
         i f   ( ! c a n H a n d l e )   {   
                 r e t u r n   f a l s e ;   
         }   
   
         g r i p . p r e v i e w . w r a p p e d V a l u e   =   o b j e c t A c t o r . g e t G r i p ( m a k e D e b u g g e e V a l u e I f N e e d e d ( _ o b j ,   v ) ) ;   
         r e t u r n   t r u e ;   
 }   
   
 f u n c t i o n   G e n e r i c O b j e c t ( o b j e c t A c t o r ,   g r i p ,   s p e c i a l S t r i n g B e h a v i o r   =   f a l s e )   {   
         l e t   { _ o b j }   =   o b j e c t A c t o r ;   
         i f   ( g r i p . p r e v i e w   | |   g r i p . d i s p l a y S t r i n g   | |   o b j e c t A c t o r . g e t G r i p D e p t h ( )   >   1 )   {   
                 r e t u r n   f a l s e ;   
         }   
   
         l e t   i   =   0 ,   n a m e s   =   [ ] ;   
         l e t   p r e v i e w   =   g r i p . p r e v i e w   =   {   
                 k i n d :   " O b j e c t " ,   
                 o w n P r o p e r t i e s :   { } / / O b j e c t . c r e a t e ( n u l l )   
         } ;   
   
         t r y   {   
                 n a m e s   =   _ o b j . g e t O w n P r o p e r t y N a m e s ( ) ;   
         }   c a t c h   ( e x )   {   
                 / /   C a l l i n g   g e t O w n P r o p e r t y N a m e s ( )   o n   s o m e   w r a p p e d   n a t i v e   p r o t o t y p e s   i s   n o t   
                 / /   a l l o w e d :   " c a n n o t   m o d i f y   p r o p e r t i e s   o f   a   W r a p p e d N a t i v e " .   S e e   b u g   9 5 2 0 9 3 .   
         }   
   
         p r e v i e w . o w n P r o p e r t i e s L e n g t h   =   n a m e s . l e n g t h ;   
   
         l e t   l e n g t h ;   
         i f   ( s p e c i a l S t r i n g B e h a v i o r )   {   
                 l e n g t h   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " l e n g t h " ) ;   
                 i f   ( t y p e o f   l e n g t h   ! =   " n u m b e r " )   {   
                         s p e c i a l S t r i n g B e h a v i o r   =   f a l s e ;   
                 }   
         }   
   
         f o r   ( l e t   n a m e   o f   n a m e s )   {   
                 i f   ( s p e c i a l S t r i n g B e h a v i o r   & &   / ^ [ 0 - 9 ] + $ / . t e s t ( n a m e ) )   {   
                         l e t   n u m   =   p a r s e I n t ( n a m e ,   1 0 ) ;   
                         i f   ( n u m . t o S t r i n g ( )   = = =   n a m e   & &   n u m   > =   0   & &   n u m   <   l e n g t h )   {   
                                 c o n t i n u e ;   
                         }   
                 }   
   
                 l e t   d e s c   =   o b j e c t A c t o r . _ p r o p e r t y D e s c r i p t o r ( n a m e ,   t r u e ) ;   
                 i f   ( ! d e s c )   {   
                         c o n t i n u e ;   
                 }   
   
                 p r e v i e w . o w n P r o p e r t i e s [ n a m e ]   =   d e s c ;   
                 i f   ( + + i   = =   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
                         b r e a k ;   
                 }   
         }   
   
         i f   ( i   <   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
                 p r e v i e w . s a f e G e t t e r V a l u e s   =   o b j e c t A c t o r . _ f i n d S a f e G e t t e r V a l u e s (   
                         O b j e c t . k e y s ( p r e v i e w . o w n P r o p e r t i e s ) ,   
                         O B J E C T _ P R E V I E W _ M A X _ I T E M S   -   i ) ;   
         }   
   
         r e t u r n   t r u e ;   
 }   
   
 / * *   
   *   M a k e   a   d e b u g g e e   v a l u e   f o r   t h e   g i v e n   o b j e c t ,   i f   n e e d e d .   P r i m i t i v e   v a l u e s   
   *   a r e   l e f t   t h e   s a m e .   
   *   
   *   U s e   c a s e :   y o u   h a v e   a   r a w   J S   o b j e c t   ( a f t e r   u n s a f e   d e r e f e r e n c e )   a n d   y o u   w a n t   t o   
   *   s e n d   i t   t o   t h e   c l i e n t .   I n   t h a t   c a s e   y o u   n e e d   t o   u s e   a n   O b j e c t A c t o r   w h i c h   
   *   r e q u i r e s   a   d e b u g g e e   v a l u e .   T h e   D e b u g g e r . O b j e c t . p r o t o t y p e . m a k e D e b u g g e e V a l u e ( )   
   *   m e t h o d   w o r k s   o n l y   f o r   J S   o b j e c t s   a n d   f u n c t i o n s .   
   *   
   *   @ p a r a m   D e b u g g e r . O b j e c t   o b j   
   *   @ p a r a m   a n y   v a l u e   
   *   @ r e t u r n   o b j e c t   
   * /   
 f u n c t i o n   m a k e D e b u g g e e V a l u e I f N e e d e d ( o b j ,   v a l u e )   {   
         i f   ( v a l u e   & &   ( t y p e o f   v a l u e   = =   " o b j e c t "   | |   t y p e o f   v a l u e   = =   " f u n c t i o n " ) )   {   
                 r e t u r n   o b j . m a k e D e b u g g e e V a l u e ( v a l u e ) ;   
         }   
         r e t u r n   v a l u e ;   
 }   
   
 / /   P r e v i e w   f u n c t i o n s   t h a t   d o   n o t   r e l y   o n   t h e   o b j e c t   c l a s s .   
 _ O b j e c t A c t o r P r e v i e w e r s . O b j e c t   =   [   
         f u n c t i o n   T y p e d A r r a y ( o b j e c t A c t o r ,   g r i p )   {   
                 l e t   { _ o b j }   =   o b j e c t A c t o r ;   
                 i f   ( T Y P E D _ A R R A Y _ C L A S S E S . i n d e x O f ( _ o b j . c l a s s )   = =   - 1 )   {   
                         r e t u r n   f a l s e ;   
                 }   
   
                 l e t   l e n g t h   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " l e n g t h " ) ;   
                 i f   ( t y p e o f   l e n g t h   ! =   " n u m b e r " )   {   
                         r e t u r n   f a l s e ;   
                 }   
   
                 g r i p . p r e v i e w   =   {   
                         k i n d :   " A r r a y L i k e " ,   
                         l e n g t h :   l e n g t h   
                 } ;   
   
                 i f   ( o b j e c t A c t o r . g e t G r i p D e p t h ( )   >   1 )   {   
                         r e t u r n   t r u e ;   
                 }   
   
                 l e t   r a w   =   _ o b j . u n s a f e D e r e f e r e n c e ( ) ;   
                 / / l e t   g l o b a l   =   C u . g e t G l o b a l F o r O b j e c t ( D e b u g g e r S e r v e r ) ;   
   
                 l e t   c l a s s P r o t o   =   g l o b a l [ _ o b j . c l a s s ] . p r o t o t y p e ;   
                 / /   T h e   X r a y   m a c h i n e r y   f o r   T y p e d A r r a y s   d e n i e s   i n d e x e d   a c c e s s   o n   t h e   g r o u n d s   
                 / /   t h a t   i t ' s   s l o w ,   a n d   a d v i s e s   c a l l e r s   t o   d o   a   s t r u c t u r e d   c l o n e   i n s t e a d .   
                 / / l e t   s a f e V i e w   =   C u . c l o n e I n t o ( c l a s s P r o t o . s u b a r r a y . c a l l ( r a w ,   0 ,   
                 / /         O B J E C T _ P R E V I E W _ M A X _ I T E M S ) ,   g l o b a l ) ;   
                 l e t   s a f e V i e w   =   c l a s s P r o t o . s u b a r r a y . c a l l ( r a w ,   0 ,   
                         O B J E C T _ P R E V I E W _ M A X _ I T E M S ) ;   
                 l e t   i t e m s   =   g r i p . p r e v i e w . i t e m s   =   [ ] ;   
                 f o r   ( l e t   i   =   0 ;   i   <   s a f e V i e w . l e n g t h ;   i + + )   {   
                         i t e m s . p u s h ( s a f e V i e w [ i ] ) ;   
                 }   
   
                 r e t u r n   t r u e ;   
         } ,   
   
         f u n c t i o n   E r r o r ( o b j e c t A c t o r ,   g r i p )   {   
                 l e t   { _ o b j }   =   o b j e c t A c t o r ;   
                 s w i t c h   ( _ o b j . c l a s s )   {   
                         c a s e   " E r r o r " :   
                         c a s e   " E v a l E r r o r " :   
                         c a s e   " R a n g e E r r o r " :   
                         c a s e   " R e f e r e n c e E r r o r " :   
                         c a s e   " S y n t a x E r r o r " :   
                         c a s e   " T y p e E r r o r " :   
                         c a s e   " U R I E r r o r " :   
                                 l e t   n a m e   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " n a m e " ) ;   
                                 l e t   m s g   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " m e s s a g e " ) ;   
                                 l e t   s t a c k   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " s t a c k " ) ;   
                                 l e t   f i l e N a m e   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " f i l e N a m e " ) ;   
                                 l e t   l i n e N u m b e r   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " l i n e N u m b e r " ) ;   
                                 l e t   c o l u m n N u m b e r   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( _ o b j ,   " c o l u m n N u m b e r " ) ;   
                                 g r i p . p r e v i e w   =   {   
                                         k i n d :   " E r r o r " ,   
                                         n a m e :   o b j e c t A c t o r . g e t G r i p ( n a m e ) ,   
                                         m e s s a g e :   o b j e c t A c t o r . g e t G r i p ( m s g ) ,   
                                         s t a c k :   o b j e c t A c t o r . g e t G r i p ( s t a c k ) ,   
                                         f i l e N a m e :   o b j e c t A c t o r . g e t G r i p ( f i l e N a m e ) ,   
                                         l i n e N u m b e r :   o b j e c t A c t o r . g e t G r i p ( l i n e N u m b e r ) ,   
                                         c o l u m n N u m b e r :   o b j e c t A c t o r . g e t G r i p ( c o l u m n N u m b e r )   
                                 } ;   
                                 r e t u r n   t r u e ;   
                         d e f a u l t :   
                                 r e t u r n   f a l s e ;   
                 }   
         } ,   
   
         / * f u n c t i o n   C S S M e d i a R u l e ( { o b j ,   h o o k s } ,   g r i p ,   r a w O b j )   {   
           i f   ( i s W o r k e r   | |   ! r a w O b j   | |   ! ( r a w O b j   i n s t a n c e o f   C i . n s I D O M C S S M e d i a R u l e ) )   {   
           r e t u r n   f a l s e ;   
           }   
           g r i p . p r e v i e w   =   {   
           k i n d :   " O b j e c t W i t h T e x t " ,   
           t e x t :   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . c o n d i t i o n T e x t ) ,   
           } ;   
           r e t u r n   t r u e ;   
           } ,   
   
           f u n c t i o n   C S S S t y l e R u l e ( { o b j ,   h o o k s } ,   g r i p ,   r a w O b j )   {   
           i f   ( i s W o r k e r   | |   ! r a w O b j   | |   ! ( r a w O b j   i n s t a n c e o f   C i . n s I D O M C S S S t y l e R u l e ) )   {   
           r e t u r n   f a l s e ;   
           }   
           g r i p . p r e v i e w   =   {   
           k i n d :   " O b j e c t W i t h T e x t " ,   
           t e x t :   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . s e l e c t o r T e x t ) ,   
           } ;   
           r e t u r n   t r u e ;   
           } ,   
   
           f u n c t i o n   O b j e c t W i t h U R L ( { o b j ,   h o o k s } ,   g r i p ,   r a w O b j )   {   
           i f   ( i s W o r k e r   | |   ! r a w O b j   | |   ! ( r a w O b j   i n s t a n c e o f   C i . n s I D O M C S S I m p o r t R u l e   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M C S S S t y l e S h e e t   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M L o c a t i o n   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M W i n d o w ) )   {   
           r e t u r n   f a l s e ;   
           }   
   
           l e t   u r l ;   
           i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M W i n d o w   & &   r a w O b j . l o c a t i o n )   {   
           u r l   =   r a w O b j . l o c a t i o n . h r e f ;   
           }   e l s e   i f   ( r a w O b j . h r e f )   {   
           u r l   =   r a w O b j . h r e f ;   
           }   e l s e   {   
           r e t u r n   f a l s e ;   
           }   
   
           g r i p . p r e v i e w   =   {   
           k i n d :   " O b j e c t W i t h U R L " ,   
           u r l :   h o o k s . c r e a t e V a l u e G r i p ( u r l ) ,   
           } ;   
   
           r e t u r n   t r u e ;   
           } , * /   
   
         / * f u n c t i o n   A r r a y L i k e ( o b j e c t A c t o r ,   g r i p ,   r a w O b j )   {   
           l e t   { _ o b j }   =   o b j e c t A c t o r ;   
           i f   ( i s W o r k e r   | |   ! r a w O b j   | |   
           o b j . c l a s s   ! =   " D O M S t r i n g L i s t "   & &   
           o b j . c l a s s   ! =   " D O M T o k e n L i s t "   & &   ! ( r a w O b j   i n s t a n c e o f   C i . n s I D O M M o z N a m e d A t t r M a p   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M C S S R u l e L i s t   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M C S S V a l u e L i s t   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M F i l e L i s t   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M F o n t F a c e L i s t   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M M e d i a L i s t   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M N o d e L i s t   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M S t y l e S h e e t L i s t ) )   {   
           r e t u r n   f a l s e ;   
           }   
   
           i f   ( t y p e o f   r a w O b j . l e n g t h   ! =   " n u m b e r " )   {   
           r e t u r n   f a l s e ;   
           }   
   
           g r i p . p r e v i e w   =   {   
           k i n d :   " A r r a y L i k e " ,   
           l e n g t h :   r a w O b j . l e n g t h ,   
           } ;   
   
           i f   ( h o o k s . g e t G r i p D e p t h ( )   >   1 )   {   
           r e t u r n   t r u e ;   
           }   
   
           l e t   i t e m s   =   g r i p . p r e v i e w . i t e m s   =   [ ] ;   
   
           f o r   ( l e t   i   =   0 ;   i   <   r a w O b j . l e n g t h   & &   
           i t e m s . l e n g t h   <   O B J E C T _ P R E V I E W _ M A X _ I T E M S ;   i + + )   {   
           l e t   v a l u e   =   m a k e D e b u g g e e V a l u e I f N e e d e d ( o b j ,   r a w O b j [ i ] ) ;   
           i t e m s . p u s h ( h o o k s . c r e a t e V a l u e G r i p ( v a l u e ) ) ;   
           }   
   
           r e t u r n   t r u e ;   
           } , * /   
   
         / * f u n c t i o n   C S S S t y l e D e c l a r a t i o n ( { o b j ,   h o o k s } ,   g r i p ,   r a w O b j )   {   
           i f   ( i s W o r k e r   | |   ! r a w O b j   | |   ! ( r a w O b j   i n s t a n c e o f   C i . n s I D O M C S S S t y l e D e c l a r a t i o n ) )   {   
           r e t u r n   f a l s e ;   
           }   
   
           g r i p . p r e v i e w   =   {   
           k i n d :   " M a p L i k e " ,   
           s i z e :   r a w O b j . l e n g t h ,   
           } ;   
   
           l e t   e n t r i e s   =   g r i p . p r e v i e w . e n t r i e s   =   [ ] ;   
   
           f o r   ( l e t   i   =   0 ;   i   <   O B J E C T _ P R E V I E W _ M A X _ I T E M S   & &   
           i   <   r a w O b j . l e n g t h ;   i + + )   {   
           l e t   p r o p   =   r a w O b j [ i ] ;   
           l e t   v a l u e   =   r a w O b j . g e t P r o p e r t y V a l u e ( p r o p ) ;   
           e n t r i e s . p u s h ( [ p r o p ,   h o o k s . c r e a t e V a l u e G r i p ( v a l u e ) ] ) ;   
           }   
   
           r e t u r n   t r u e ;   
           } ,   
   
           f u n c t i o n   D O M N o d e ( { o b j ,   h o o k s } ,   g r i p ,   r a w O b j )   {   
           i f   ( i s W o r k e r   | |   o b j . c l a s s   = =   " O b j e c t "   | |   ! r a w O b j   | |   ! ( r a w O b j   i n s t a n c e o f   C i . n s I D O M N o d e ) )   {   
           r e t u r n   f a l s e ;   
           }   
   
           l e t   p r e v i e w   =   g r i p . p r e v i e w   =   {   
           k i n d :   " D O M N o d e " ,   
           n o d e T y p e :   r a w O b j . n o d e T y p e ,   
           n o d e N a m e :   r a w O b j . n o d e N a m e ,   
           } ;   
   
           i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M D o c u m e n t   & &   r a w O b j . l o c a t i o n )   {   
           p r e v i e w . l o c a t i o n   =   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . l o c a t i o n . h r e f ) ;   
           }   e l s e   i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M D o c u m e n t F r a g m e n t )   {   
           p r e v i e w . c h i l d N o d e s L e n g t h   =   r a w O b j . c h i l d N o d e s . l e n g t h ;   
   
           i f   ( h o o k s . g e t G r i p D e p t h ( )   <   2 )   {   
           p r e v i e w . c h i l d N o d e s   =   [ ] ;   
           f o r   ( l e t   n o d e   o f   r a w O b j . c h i l d N o d e s )   {   
           l e t   a c t o r   =   h o o k s . c r e a t e V a l u e G r i p ( o b j . m a k e D e b u g g e e V a l u e ( n o d e ) ) ;   
           p r e v i e w . c h i l d N o d e s . p u s h ( a c t o r ) ;   
           i f   ( p r e v i e w . c h i l d N o d e s . l e n g t h   = =   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
           b r e a k ;   
           }   
           }   
           }   
           }   e l s e   i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M E l e m e n t )   {   
           / /   A d d   p r e v i e w   f o r   D O M   e l e m e n t   a t t r i b u t e s .   
           i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M H T M L E l e m e n t )   {   
           p r e v i e w . n o d e N a m e   =   p r e v i e w . n o d e N a m e . t o L o w e r C a s e ( ) ;   
           }   
   
           l e t   i   =   0 ;   
           p r e v i e w . a t t r i b u t e s   =   { } ;   
           p r e v i e w . a t t r i b u t e s L e n g t h   =   r a w O b j . a t t r i b u t e s . l e n g t h ;   
           f o r   ( l e t   a t t r   o f   r a w O b j . a t t r i b u t e s )   {   
           p r e v i e w . a t t r i b u t e s [ a t t r . n o d e N a m e ]   =   h o o k s . c r e a t e V a l u e G r i p ( a t t r . v a l u e ) ;   
           i f   ( + + i   = =   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
           b r e a k ;   
           }   
           }   
           }   e l s e   i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M A t t r )   {   
           p r e v i e w . v a l u e   =   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . v a l u e ) ;   
           }   e l s e   i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M T e x t   | |   
           r a w O b j   i n s t a n c e o f   C i . n s I D O M C o m m e n t )   {   
           p r e v i e w . t e x t C o n t e n t   =   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . t e x t C o n t e n t ) ;   
           }   
   
           r e t u r n   t r u e ;   
           } ,   
   
           f u n c t i o n   D O M E v e n t ( { o b j ,   h o o k s } ,   g r i p ,   r a w O b j )   {   
           i f   ( i s W o r k e r   | |   ! r a w O b j   | |   ! ( r a w O b j   i n s t a n c e o f   C i . n s I D O M E v e n t ) )   {   
           r e t u r n   f a l s e ;   
           }   
   
           l e t   p r e v i e w   =   g r i p . p r e v i e w   =   {   
           k i n d :   " D O M E v e n t " ,   
           t y p e :   r a w O b j . t y p e ,   
           p r o p e r t i e s :   O b j e c t . c r e a t e ( n u l l ) ,   
           } ;   
   
           i f   ( h o o k s . g e t G r i p D e p t h ( )   <   2 )   {   
           l e t   t a r g e t   =   o b j . m a k e D e b u g g e e V a l u e ( r a w O b j . t a r g e t ) ;   
           p r e v i e w . t a r g e t   =   h o o k s . c r e a t e V a l u e G r i p ( t a r g e t ) ;   
           }   
   
           l e t   p r o p s   =   [ ] ;   
           i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M M o u s e E v e n t )   {   
           p r o p s . p u s h ( " b u t t o n s " ,   " c l i e n t X " ,   " c l i e n t Y " ,   " l a y e r X " ,   " l a y e r Y " ) ;   
           }   e l s e   i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M K e y E v e n t )   {   
           l e t   m o d i f i e r s   =   [ ] ;   
           i f   ( r a w O b j . a l t K e y )   {   
           m o d i f i e r s . p u s h ( " A l t " ) ;   
           }   
           i f   ( r a w O b j . c t r l K e y )   {   
           m o d i f i e r s . p u s h ( " C o n t r o l " ) ;   
           }   
           i f   ( r a w O b j . m e t a K e y )   {   
           m o d i f i e r s . p u s h ( " M e t a " ) ;   
           }   
           i f   ( r a w O b j . s h i f t K e y )   {   
           m o d i f i e r s . p u s h ( " S h i f t " ) ;   
           }   
           p r e v i e w . e v e n t K i n d   =   " k e y " ;   
           p r e v i e w . m o d i f i e r s   =   m o d i f i e r s ;   
   
           p r o p s . p u s h ( " k e y " ,   " c h a r C o d e " ,   " k e y C o d e " ) ;   
           }   e l s e   i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M T r a n s i t i o n E v e n t )   {   
           p r o p s . p u s h ( " p r o p e r t y N a m e " ,   " p s e u d o E l e m e n t " ) ;   
           }   e l s e   i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M A n i m a t i o n E v e n t )   {   
           p r o p s . p u s h ( " a n i m a t i o n N a m e " ,   " p s e u d o E l e m e n t " ) ;   
           }   e l s e   i f   ( r a w O b j   i n s t a n c e o f   C i . n s I D O M C l i p b o a r d E v e n t )   {   
           p r o p s . p u s h ( " c l i p b o a r d D a t a " ) ;   
           }   
   
           / /   A d d   e v e n t - s p e c i f i c   p r o p e r t i e s .   
           f o r   ( l e t   p r o p   o f   p r o p s )   {   
           l e t   v a l u e   =   r a w O b j [ p r o p ] ;   
           i f   ( v a l u e   & &   ( t y p e o f   v a l u e   = =   " o b j e c t "   | |   t y p e o f   v a l u e   = =   " f u n c t i o n " ) )   {   
           / /   S k i p   p r o p e r t i e s   p o i n t i n g   t o   o b j e c t s .   
           i f   ( h o o k s . g e t G r i p D e p t h ( )   >   1 )   {   
           c o n t i n u e ;   
           }   
           v a l u e   =   o b j . m a k e D e b u g g e e V a l u e ( v a l u e ) ;   
           }   
           p r e v i e w . p r o p e r t i e s [ p r o p ]   =   h o o k s . c r e a t e V a l u e G r i p ( v a l u e ) ;   
           }   
   
           / /   A d d   a n y   p r o p e r t i e s   w e   f i n d   o n   t h e   e v e n t   o b j e c t .   
           i f   ( ! p r o p s . l e n g t h )   {   
           l e t   i   =   0 ;   
           f o r   ( l e t   p r o p   i n   r a w O b j )   {   
           l e t   v a l u e   =   r a w O b j [ p r o p ] ;   
           i f   ( p r o p   = =   " t a r g e t "   | |   p r o p   = =   " t y p e "   | |   v a l u e   = = =   n u l l   | |   
           t y p e o f   v a l u e   = =   " f u n c t i o n " )   {   
           c o n t i n u e ;   
           }   
           i f   ( v a l u e   & &   t y p e o f   v a l u e   = =   " o b j e c t " )   {   
           i f   ( h o o k s . g e t G r i p D e p t h ( )   >   1 )   {   
           c o n t i n u e ;   
           }   
           v a l u e   =   o b j . m a k e D e b u g g e e V a l u e ( v a l u e ) ;   
           }   
           p r e v i e w . p r o p e r t i e s [ p r o p ]   =   h o o k s . c r e a t e V a l u e G r i p ( v a l u e ) ;   
           i f   ( + + i   = =   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
           b r e a k ;   
           }   
           }   
           }   
   
           r e t u r n   t r u e ;   
           } ,   
   
           f u n c t i o n   D O M E x c e p t i o n ( { o b j ,   h o o k s } ,   g r i p ,   r a w O b j )   {   
           i f   ( i s W o r k e r   | |   ! r a w O b j   | |   ! ( r a w O b j   i n s t a n c e o f   C i . n s I D O M D O M E x c e p t i o n ) )   {   
           r e t u r n   f a l s e ;   
           }   
   
           g r i p . p r e v i e w   =   {   
           k i n d :   " D O M E x c e p t i o n " ,   
           n a m e :   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . n a m e ) ,   
           m e s s a g e :   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . m e s s a g e ) ,   
           c o d e :   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . c o d e ) ,   
           r e s u l t :   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . r e s u l t ) ,   
           f i l e n a m e :   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . f i l e n a m e ) ,   
           l i n e N u m b e r :   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . l i n e N u m b e r ) ,   
           c o l u m n N u m b e r :   h o o k s . c r e a t e V a l u e G r i p ( r a w O b j . c o l u m n N u m b e r ) ,   
           } ;   
   
           r e t u r n   t r u e ;   
           } , * /   
   
         / * f u n c t i o n   P s e u d o A r r a y ( { o b j ,   h o o k s } ,   g r i p ,   r a w O b j )   {   
           l e t   l e n g t h   =   0 ;   
   
           / /   M a k i n g   s u r e   a l l   k e y s   a r e   n u m b e r s   f r o m   0   t o   l e n g t h - 1   
           l e t   k e y s   =   o b j . g e t O w n P r o p e r t y N a m e s ( ) ;   
           i f   ( k e y s . l e n g t h   = =   0 )   {   
           r e t u r n   f a l s e ;   
           }   
           f o r   ( l e t   k e y   o f   k e y s )   {   
           i f   ( i s N a N ( k e y )   | |   k e y   ! =   l e n g t h + + )   {   
           r e t u r n   f a l s e ;   
           }   
           }   
   
           g r i p . p r e v i e w   =   {   
           k i n d :   " A r r a y L i k e " ,   
           l e n g t h :   l e n g t h ,   
           } ;   
   
           / /   A v o i d   r e c u r s i v e   o b j e c t   g r i p s .   
           i f   ( h o o k s . g e t G r i p D e p t h ( )   >   1 )   {   
           r e t u r n   t r u e ;   
           }   
   
           l e t   i t e m s   =   g r i p . p r e v i e w . i t e m s   =   [ ] ;   
   
           l e t   i   =   0 ;   
           f o r   ( l e t   k e y   o f   k e y s )   {   
           i f   ( r a w O b j . h a s O w n P r o p e r t y ( k e y )   & &   i + +   <   O B J E C T _ P R E V I E W _ M A X _ I T E M S )   {   
           l e t   v a l u e   =   m a k e D e b u g g e e V a l u e I f N e e d e d ( o b j ,   r a w O b j [ k e y ] ) ;   
           i t e m s . p u s h ( h o o k s . c r e a t e V a l u e G r i p ( v a l u e ) ) ;   
           }   
           }   
   
           r e t u r n   t r u e ;   
           } , * /   
   
         G e n e r i c O b j e c t   
 ] ;   
   
 e x p o r t   c o n s t   O b j e c t A c t o r P r e v i e w e r s   =   _ O b j e c t A c t o r P r e v i e w e r s ; n  H   ��
 D E V T O O L S / S T R I N G I F Y . J S       0	        i m p o r t   *   a s   D e v T o o l s U t i l s   f r o m   ' D e v T o o l s / D e v T o o l s U t i l s . j s ' ;   
   
 / * *   
   *   S t r i n g i f y   a   D e b u g g e r . O b j e c t   b a s e d   o n   i t s   c l a s s .   
   *   
   *   @ p a r a m   D e b u g g e r . O b j e c t   o b j   
   *                 T h e   o b j e c t   t o   s t r i n g i f y .   
   *   @ r e t u r n   S t r i n g   
   *                   T h e   s t r i n g i f i c a t i o n   f o r   t h e   o b j e c t .   
   * /   
 e x p o r t   f u n c t i o n   s t r i n g i f y ( o b j )   {   
         i f   ( o b j . c l a s s   = =   " D e a d O b j e c t " )   {   
                 c o n s t   e r r o r   =   n e w   E r r o r ( " D e a d   o b j e c t   e n c o u n t e r e d . " ) ;   
                 D e v T o o l s U t i l s . r e p o r t E x c e p t i o n ( " s t r i n g i f y " ,   e r r o r ) ;   
                 r e t u r n   " < d e a d   o b j e c t > " ;   
         }   
   
         c o n s t   s t r i n g i f i e r   =   s t r i n g i f i e r s [ o b j . c l a s s ]   | |   s t r i n g i f i e r s . O b j e c t ;   
   
         t r y   {   
                 r e t u r n   s t r i n g i f i e r ( o b j ) ;   
         }   c a t c h   ( e )   {   
                 D e v T o o l s U t i l s . r e p o r t E x c e p t i o n ( " s t r i n g i f y " ,   e ) ;   
                 r e t u r n   " < f a i l e d   t o   s t r i n g i f y   o b j e c t > " ;   
         }   
 } ;   
   
 / * *   
   *   D e t e r m i n e   i f   a   g i v e n   v a l u e   i s   n o n - p r i m i t i v e .   
   *   
   *   @ p a r a m   A n y   v a l u e   
   *                 T h e   v a l u e   t o   t e s t .   
   *   @ r e t u r n   B o o l e a n   
   *                   W h e t h e r   t h e   v a l u e   i s   n o n - p r i m i t i v e .   
   * /   
 f u n c t i o n   i s O b j e c t ( v a l u e )   {   
         c o n s t   t y p e   =   t y p e o f   v a l u e ;   
         r e t u r n   t y p e   = =   " o b j e c t "   ?   v a l u e   ! = =   n u l l   :   t y p e   = =   " f u n c t i o n " ;   
 }   
   
 / * *   
   *   C r e a t e   a   f u n c t i o n   t h a t   c a n   s a f e l y   s t r i n g i f y   D e b u g g e r . O b j e c t s   o f   a   g i v e n   
   *   b u i l t i n   t y p e .   
   *   
   *   @ p a r a m   F u n c t i o n   c t o r   
   *                 T h e   b u i l t i n   c l a s s   c o n s t r u c t o r .   
   *   @ r e t u r n   F u n c t i o n   
   *                   T h e   s t r i n g i f i e r   f o r   t h e   c l a s s .   
   * /   
 f u n c t i o n   c r e a t e B u i l t i n S t r i n g i f i e r ( c t o r )   {   
         r e t u r n   o b j   = >   c t o r . p r o t o t y p e . t o S t r i n g . c a l l ( o b j . u n s a f e D e r e f e r e n c e ( ) ) ;   
 }   
   
 / * *   
   *   S t r i n g i f y   a   D e b u g g e r . O b j e c t - w r a p p e d   E r r o r   i n s t a n c e .   
   *   
   *   @ p a r a m   D e b u g g e r . O b j e c t   o b j   
   *                 T h e   o b j e c t   t o   s t r i n g i f y .   
   *   @ r e t u r n   S t r i n g   
   *                   T h e   s t r i n g i f i c a t i o n   o f   t h e   o b j e c t .   
   * /   
 f u n c t i o n   e r r o r S t r i n g i f y ( o b j )   {   
         l e t   n a m e   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( o b j ,   " n a m e " ) ;   
         i f   ( n a m e   = = =   " "   | |   n a m e   = = =   u n d e f i n e d )   {   
                 n a m e   =   o b j . c l a s s ;   
         }   e l s e   i f   ( i s O b j e c t ( n a m e ) )   {   
                 n a m e   =   s t r i n g i f y ( n a m e ) ;   
         }   
   
         l e t   m e s s a g e   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( o b j ,   " m e s s a g e " ) ;   
         i f   ( i s O b j e c t ( m e s s a g e ) )   {   
                 m e s s a g e   =   s t r i n g i f y ( m e s s a g e ) ;   
         }   
   
         i f   ( m e s s a g e   = = =   " "   | |   m e s s a g e   = = =   u n d e f i n e d )   {   
                 r e t u r n   n a m e ;   
         }   
         r e t u r n   n a m e   +   " :   "   +   m e s s a g e ;   
 }   
   
 / /   U s e d   t o   p r e v e n t   i n f i n i t e   r e c u r s i o n   w h e n   a n   a r r a y   i s   f o u n d   i n s i d e   i t s e l f .   
 l e t   s e e n   =   n u l l ;   
   
 c o n s t   s t r i n g i f i e r s   =   {   
         E r r o r :   e r r o r S t r i n g i f y ,   
         E v a l E r r o r :   e r r o r S t r i n g i f y ,   
         R a n g e E r r o r :   e r r o r S t r i n g i f y ,   
         R e f e r e n c e E r r o r :   e r r o r S t r i n g i f y ,   
         S y n t a x E r r o r :   e r r o r S t r i n g i f y ,   
         T y p e E r r o r :   e r r o r S t r i n g i f y ,   
         U R I E r r o r :   e r r o r S t r i n g i f y ,   
         B o o l e a n :   c r e a t e B u i l t i n S t r i n g i f i e r ( B o o l e a n ) ,   
         F u n c t i o n :   c r e a t e B u i l t i n S t r i n g i f i e r ( F u n c t i o n ) ,   
         N u m b e r :   c r e a t e B u i l t i n S t r i n g i f i e r ( N u m b e r ) ,   
         R e g E x p :   c r e a t e B u i l t i n S t r i n g i f i e r ( R e g E x p ) ,   
         S t r i n g :   c r e a t e B u i l t i n S t r i n g i f i e r ( S t r i n g ) ,   
         O b j e c t :   o b j   = >   " [ o b j e c t   "   +   o b j . c l a s s   +   " ] " ,   
         A r r a y :   o b j   = >   {   
                 / /   I f   w e ' r e   a t   t h e   t o p   l e v e l   t h e n   w e   n e e d   t o   c r e a t e   t h e   S e t   f o r   t r a c k i n g   
                 / /   p r e v i o u s l y   s t r i n g i f i e d   a r r a y s .   
                 c o n s t   t o p L e v e l   =   ! s e e n ;   
                 i f   ( t o p L e v e l )   {   
                         s e e n   =   n e w   S e t ( ) ;   
                 }   e l s e   i f   ( s e e n . h a s ( o b j ) )   {   
                         r e t u r n   " " ;   
                 }   
   
                 s e e n . a d d ( o b j ) ;   
   
                 c o n s t   l e n   =   D e v T o o l s U t i l s . g e t P r o p e r t y ( o b j ,   " l e n g t h " ) ;   
                 l e t   s t r i n g   =   " " ;   
   
                 / /   T h e   f o l l o w i n g   c h e c k   i s   o n l y   r e q u i r e d   b e c a u s e   t h e   d e b u g g e e   c o u l d   p o s s i b l y   
                 / /   b e   a   P r o x y   a n d   r e t u r n   a n y   v a l u e .   F o r   n o r m a l   o b j e c t s ,   a r r a y . l e n g t h   i s   
                 / /   a l w a y s   a   n o n - n e g a t i v e   i n t e g e r .   
                 i f   ( t y p e o f   l e n   = =   " n u m b e r "   & &   l e n   >   0 )   {   
                         f o r   ( l e t   i   =   0 ;   i   <   l e n ;   i + + )   {   
                                 c o n s t   d e s c   =   o b j . g e t O w n P r o p e r t y D e s c r i p t o r ( i ) ;   
                                 i f   ( d e s c )   {   
                                         c o n s t   {   v a l u e   }   =   d e s c ;   
                                         i f   ( v a l u e   ! =   n u l l )   {   
                                                 s t r i n g   + =   i s O b j e c t ( v a l u e )   ?   s t r i n g i f y ( v a l u e )   :   v a l u e ;   
                                         }   
                                 }   
   
                                 i f   ( i   <   l e n   -   1 )   {   
                                         s t r i n g   + =   " , " ;   
                                 }   
                         }   
                 }   
   
                 i f   ( t o p L e v e l )   {   
                         s e e n   =   n u l l ;   
                 }   
   
                 r e t u r n   s t r i n g ;   
         }   
 } ;   
   
   �  <   ��
 M O D U L E L O A D E R . J S       0	        / *   T h i s   S o u r c e   C o d e   F o r m   i s   s u b j e c t   t o   t h e   t e r m s   o f   t h e   M o z i l l a   P u b l i c   
   *   L i c e n s e ,   v .   2 . 0 .   I f   a   c o p y   o f   t h e   M P L   w a s   n o t   d i s t r i b u t e d   w i t h   t h i s   
   *   f i l e ,   Y o u   c a n   o b t a i n   o n e   a t   h t t p : / / m o z i l l a . o r g / M P L / 2 . 0 / .   * /   
   
 / /   A   b a s i c   s y n c h r o n o u s   m o d u l e   l o a d e r   f o r   t e s t i n g   t h e   s h e l l .   
 l e t   { c o r e M o d u l e s P a t h ,   p a r s e M o d u l e ,   s e t M o d u l e R e s o l v e H o o k ,   p a r s e M o d u l e R e s ,   _ c o r e M o d u l e s I n R e s }   =   p r o c e s s . b i n d i n g ( ' m o d u l e s ' ) ;   
 l e t   { l o a d F i l e ,   r e l T o A b s }   =   p r o c e s s . b i n d i n g ( ' f s ' ) ;   
   
 R e f l e c t . L o a d e r   =   n e w   c l a s s   {   
         c o n s t r u c t o r ( )   {   
                 t h i s . r e g i s t r y   =   n e w   M a p ( ) ;   
                 t h i s . l o a d P a t h   =   c o r e M o d u l e s P a t h ;   
         }   
   
         r e s o l v e ( n a m e )   {   
                 r e t u r n   r e l T o A b s ( t h i s . l o a d P a t h ,   n a m e ) ;   
         }   
   
         f e t c h ( p a t h )   {   
                 / / r e t u r n   o s . f i l e . r e a d F i l e ( p a t h ) ;   
                 r e t u r n   l o a d F i l e ( p a t h ) ;   
         }   
   
         l o a d A n d P a r s e ( n a m e )   {   
                 l e t   p a t h   =   _ c o r e M o d u l e s I n R e s   ?   n a m e . t o U p p e r C a s e ( )   :   t h i s . r e s o l v e ( n a m e ) ;   
   
                 i f   ( t h i s . r e g i s t r y . h a s ( p a t h ) )   
                         r e t u r n   t h i s . r e g i s t r y . g e t ( p a t h ) ;   
   
                 l e t   m o d u l e ;   
                 i f   ( _ c o r e M o d u l e s I n R e s )   {   
                         m o d u l e   =   p a r s e M o d u l e R e s ( p a t h ) ;   
                 }   e l s e   {   
                         l e t   s o u r c e   =   t h i s . f e t c h ( p a t h ) ;   
                         m o d u l e   =   p a r s e M o d u l e ( s o u r c e ,   p a t h ) ;   
                 }   
                 t h i s . r e g i s t r y . s e t ( p a t h ,   m o d u l e ) ;   
                 r e t u r n   m o d u l e ;   
         }   
   
         [ " i m p o r t " ] ( n a m e ,   r e f e r r e r )   {   
                 l e t   m o d u l e   =   t h i s . l o a d A n d P a r s e ( n a m e ) ;   
                 m o d u l e . d e c l a r a t i o n I n s t a n t i a t i o n ( ) ;   
                 r e t u r n   m o d u l e . e v a l u a t i o n ( ) ;   
         }   
 } ;   
 s e t M o d u l e R e s o l v e H o o k ( ( m o d u l e ,   r e q u e s t N a m e )   = >   R e f l e c t . L o a d e r . l o a d A n d P a r s e ( r e q u e s t N a m e ) ) ;   
   
   �  L   ��
 N O D E _ M O D U L E S / A S S E R T . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / /   h t t p : / / w i k i . c o m m o n j s . o r g / w i k i / U n i t _ T e s t i n g / 1 . 0   
 / /   
 / /   T H I S   I S   N O T   T E S T E D   N O R   L I K E L Y   T O   W O R K   O U T S I D E   V 8 !   
 / /   
 / /   O r i g i n a l l y   f r o m   n a r w h a l . j s   ( h t t p : / / n a r w h a l j s . o r g )   
 / /   C o p y r i g h t   ( c )   2 0 0 9   T h o m a s   R o b i n s o n   < 2 8 0 n o r t h . c o m >   
 / /   
 / /   P e r m i s s i o n   i s   h e r e b y   g r a n t e d ,   f r e e   o f   c h a r g e ,   t o   a n y   p e r s o n   o b t a i n i n g   a   c o p y   
 / /   o f   t h i s   s o f t w a r e   a n d   a s s o c i a t e d   d o c u m e n t a t i o n   f i l e s   ( t h e   ' S o f t w a r e ' ) ,   t o   
 / /   d e a l   i n   t h e   S o f t w a r e   w i t h o u t   r e s t r i c t i o n ,   i n c l u d i n g   w i t h o u t   l i m i t a t i o n   t h e   
 / /   r i g h t s   t o   u s e ,   c o p y ,   m o d i f y ,   m e r g e ,   p u b l i s h ,   d i s t r i b u t e ,   s u b l i c e n s e ,   a n d / o r   
 / /   s e l l   c o p i e s   o f   t h e   S o f t w a r e ,   a n d   t o   p e r m i t   p e r s o n s   t o   w h o m   t h e   S o f t w a r e   i s   
 / /   f u r n i s h e d   t o   d o   s o ,   s u b j e c t   t o   t h e   f o l l o w i n g   c o n d i t i o n s :   
 / /   
 / /   T h e   a b o v e   c o p y r i g h t   n o t i c e   a n d   t h i s   p e r m i s s i o n   n o t i c e   s h a l l   b e   i n c l u d e d   i n   
 / /   a l l   c o p i e s   o r   s u b s t a n t i a l   p o r t i o n s   o f   t h e   S o f t w a r e .   
 / /   
 / /   T H E   S O F T W A R E   I S   P R O V I D E D   ' A S   I S ' ,   W I T H O U T   W A R R A N T Y   O F   A N Y   K I N D ,   E X P R E S S   O R   
 / /   I M P L I E D ,   I N C L U D I N G   B U T   N O T   L I M I T E D   T O   T H E   W A R R A N T I E S   O F   M E R C H A N T A B I L I T Y ,   
 / /   F I T N E S S   F O R   A   P A R T I C U L A R   P U R P O S E   A N D   N O N I N F R I N G E M E N T .   I N   N O   E V E N T   S H A L L   T H E   
 / /   A U T H O R S   B E   L I A B L E   F O R   A N Y   C L A I M ,   D A M A G E S   O R   O T H E R   L I A B I L I T Y ,   W H E T H E R   I N   A N   
 / /   A C T I O N   O F   C O N T R A C T ,   T O R T   O R   O T H E R W I S E ,   A R I S I N G   F R O M ,   O U T   O F   O R   I N   C O N N E C T I O N   
 / /   W I T H   T H E   S O F T W A R E   O R   T H E   U S E   O R   O T H E R   D E A L I N G S   I N   T H E   S O F T W A R E .   
   
 ' u s e   s t r i c t ' ;   
   
 / * *   
   *   A s s e r t i o n s   
   *   @ m o d u l e   a s s e r t   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 / /   U T I L I T Y   
 c o n s t   c o m p a r e   =   p r o c e s s . b i n d i n g ( ' b u f f e r ' ) . c o m p a r e ;   
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
 c o n s t   B u f f e r   =   r e q u i r e ( ' b u f f e r ' ) . B u f f e r ;   
 c o n s t   p T o S t r i n g   =   ( o b j )   = >   O b j e c t . p r o t o t y p e . t o S t r i n g . c a l l ( o b j ) ;   
   
 / /   1 .   T h e   a s s e r t   m o d u l e   p r o v i d e s   f u n c t i o n s   t h a t   t h r o w   
 / /   A s s e r t i o n E r r o r ' s   w h e n   p a r t i c u l a r   c o n d i t i o n s   a r e   n o t   m e t .   T h e   
 / /   a s s e r t   m o d u l e   m u s t   c o n f o r m   t o   t h e   f o l l o w i n g   i n t e r f a c e .   
   
 c o n s t   a s s e r t   =   m o d u l e . e x p o r t s   =   o k ;   
   
 / /   2 .   T h e   A s s e r t i o n E r r o r   i s   d e f i n e d   i n   a s s e r t .   
 / /   n e w   a s s e r t . A s s e r t i o n E r r o r ( {   m e s s a g e :   m e s s a g e ,   
 / /                                                           a c t u a l :   a c t u a l ,   
 / /                                                           e x p e c t e d :   e x p e c t e d   } )   
   
 a s s e r t . A s s e r t i o n E r r o r   =   f u n c t i o n   A s s e r t i o n E r r o r ( o p t i o n s )   {   
     t h i s . n a m e   =   ' A s s e r t i o n E r r o r ' ;   
     t h i s . a c t u a l   =   o p t i o n s . a c t u a l ;   
     t h i s . e x p e c t e d   =   o p t i o n s . e x p e c t e d ;   
     t h i s . o p e r a t o r   =   o p t i o n s . o p e r a t o r ;   
   
     i f   ( o p t i o n s . m e s s a g e )   {   
         t h i s . m e s s a g e   =   o p t i o n s . m e s s a g e ;   
         t h i s . g e n e r a t e d M e s s a g e   =   f a l s e ;   
     }   e l s e   {   
         t h i s . m e s s a g e   =   g e t M e s s a g e ( t h i s ) ;   
         t h i s . g e n e r a t e d M e s s a g e   =   t r u e ;   
     }   
     v a r   s t a c k S t a r t F u n c t i o n   =   o p t i o n s . s t a c k S t a r t F u n c t i o n   | |   f a i l ;   
   i f   ( E r r o r . c a p t u r e S t a c k T r a c e )   {   
         / /   C h r o m e   a n d   N o d e J S   
         E r r o r . c a p t u r e S t a c k T r a c e ( t h i s ,   s t a c k S t a r t F u n c t i o n ) ;   
     }   e l s e   {   
           / /   F F ,   I E   1 0 +   a n d   S a f a r i   6 + .   F a l l b a c k   f o r   o t h e r s   
           l e t   t m p _ s t a c k   =   ( n e w   E r r o r ) . s t a c k . s p l i t ( " \ n " ) . s l i c e ( 1 ) ,   
                   r e   =   / ^ ( . * ? ) @ ( . * ? ) : ( . * ? ) $ / . e x e c ( t m p _ s t a c k [ 1 ] ) ;   / / [ u n d e f ,   u n d e f ,   t h i s . f i l e N a m e ,   t h i s . l i n e N u m b e r ]   =   r e   
           t h i s . f i l e N a m e   =   r e [ 2 ] ;   
           t h i s . l i n e N u m b e r   =   r e [ 3 ] ;   
           t h i s . s t a c k   =   t m p _ s t a c k . j o i n ( " \ n " ) ;   
   }   
 } ;   
   
 / /   a s s e r t . A s s e r t i o n E r r o r   i n s t a n c e o f   E r r o r   
 u t i l . i n h e r i t s ( a s s e r t . A s s e r t i o n E r r o r ,   E r r o r ) ;   
   
 f u n c t i o n   t r u n c a t e ( s ,   n )   {   
     r e t u r n   s . s l i c e ( 0 ,   n ) ;   
 }   
   
 f u n c t i o n   g e t M e s s a g e ( s e l f )   {   
     r e t u r n   t r u n c a t e ( u t i l . i n s p e c t ( s e l f . a c t u a l ) ,   1 2 8 )   +   '   '   +   
                   s e l f . o p e r a t o r   +   '   '   +   
                   t r u n c a t e ( u t i l . i n s p e c t ( s e l f . e x p e c t e d ) ,   1 2 8 ) ;   
 }   
   
 / /   A t   p r e s e n t   o n l y   t h e   t h r e e   k e y s   m e n t i o n e d   a b o v e   a r e   u s e d   a n d   
 / /   u n d e r s t o o d   b y   t h e   s p e c .   I m p l e m e n t a t i o n s   o r   s u b   m o d u l e s   c a n   p a s s   
 / /   o t h e r   k e y s   t o   t h e   A s s e r t i o n E r r o r ' s   c o n s t r u c t o r   -   t h e y   w i l l   b e   
 / /   i g n o r e d .   
   
 / /   3 .   A l l   o f   t h e   f o l l o w i n g   f u n c t i o n s   m u s t   t h r o w   a n   A s s e r t i o n E r r o r   
 / /   w h e n   a   c o r r e s p o n d i n g   c o n d i t i o n   i s   n o t   m e t ,   w i t h   a   m e s s a g e   t h a t   
 / /   m a y   b e   u n d e f i n e d   i f   n o t   p r o v i d e d .     A l l   a s s e r t i o n   m e t h o d s   p r o v i d e   
 / /   b o t h   t h e   a c t u a l   a n d   e x p e c t e d   v a l u e s   t o   t h e   a s s e r t i o n   e r r o r   f o r   
 / /   d i s p l a y   p u r p o s e s .   
   
 / * *   
   *   T h r o w s   a n   e x c e p t i o n   t h a t   d i s p l a y s   t h e   v a l u e s   f o r   a c t u a l   a n d   e x p e c t e d   s e p a r a t e d   b y   t h e   p r o v i d e d   o p e r a t o r .   
   *   @ p a r a m   a c t u a l   
   *   @ p a r a m   e x p e c t e d   
   *   @ p a r a m   m e s s a g e   
   *   @ p a r a m   o p e r a t o r   
   *   @ p a r a m   s t a c k S t a r t F u n c t i o n   
   * /   
 f u n c t i o n   f a i l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e ,   o p e r a t o r ,   s t a c k S t a r t F u n c t i o n )   {   
     t h r o w   n e w   a s s e r t . A s s e r t i o n E r r o r ( {   
         m e s s a g e :   m e s s a g e ,   
         a c t u a l :   a c t u a l ,   
         e x p e c t e d :   e x p e c t e d ,   
         o p e r a t o r :   o p e r a t o r ,   
         s t a c k S t a r t F u n c t i o n :   s t a c k S t a r t F u n c t i o n   
     } ) ;   
 }   
   
 / /   E X T E N S I O N !   a l l o w s   f o r   w e l l   b e h a v e d   e r r o r s   d e f i n e d   e l s e w h e r e .   
 a s s e r t . f a i l   =   f a i l ;   
   
 / /   4 .   P u r e   a s s e r t i o n   t e s t s   w h e t h e r   a   v a l u e   i s   t r u t h y ,   a s   d e t e r m i n e d   
 / /   b y   ! ! g u a r d .   
 / /   a s s e r t . o k ( g u a r d ,   m e s s a g e _ o p t ) ;   
 / /   T h i s   s t a t e m e n t   i s   e q u i v a l e n t   t o   a s s e r t . e q u a l ( t r u e ,   ! ! g u a r d ,   
 / /   m e s s a g e _ o p t ) ; .   T o   t e s t   s t r i c t l y   f o r   t h e   v a l u e   t r u e ,   u s e   
 / /   a s s e r t . s t r i c t E q u a l ( t r u e ,   g u a r d ,   m e s s a g e _ o p t ) ; .   
 / * *   
   *   T e s t s   i f   v a l u e   i s   t r u t h y ,   i t   i s   e q u i v a l e n t   t o   a s s e r t . e q u a l ( t r u e ,   ! ! v a l u e ,   m e s s a g e ) ;   
   *   @ p a r a m   v a l u e   
   *   @ p a r a m   m e s s a g e   
   * /   
 f u n c t i o n   o k ( v a l u e ,   m e s s a g e )   {   
     i f   ( ! v a l u e )   f a i l ( v a l u e ,   t r u e ,   m e s s a g e ,   ' = = ' ,   a s s e r t . o k ) ;   
 }   
 a s s e r t . o k   =   o k ;   
   
 / /   5 .   T h e   e q u a l i t y   a s s e r t i o n   t e s t s   s h a l l o w ,   c o e r c i v e   e q u a l i t y   w i t h   
 / /   = = .   
 / /   a s s e r t . e q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e _ o p t ) ;   
   
 / * *   
   *   T e s t s   s h a l l o w ,   c o e r c i v e   e q u a l i t y   w i t h   t h e   e q u a l   c o m p a r i s o n   o p e r a t o r   (   = =   ) .   
   *   @ p a r a m   a c t u a l   
   *   @ p a r a m   e x p e c t e d   
   *   @ p a r a m   { S t r i n g }   [ m e s s a g e ]   
   * /   
 m o d u l e . e x p o r t s . e q u a l   =   f u n c t i o n   e q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e )   {   
     i f   ( a c t u a l   ! =   e x p e c t e d )   f a i l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e ,   ' = = ' ,   a s s e r t . e q u a l ) ;   
 } ;   
   
 / /   6 .   T h e   n o n - e q u a l i t y   a s s e r t i o n   t e s t s   f o r   w h e t h e r   t w o   o b j e c t s   a r e   n o t   e q u a l   
 / /   w i t h   ! =   a s s e r t . n o t E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e _ o p t ) ;   
   
 / * *   
   *   T e s t s   s h a l l o w ,   c o e r c i v e   n o n - e q u a l i t y   w i t h   t h e   n o t   e q u a l   c o m p a r i s o n   o p e r a t o r   (   ! =   ) .   
   *   @ p a r a m   a c t u a l   
   *   @ p a r a m   e x p e c t e d   
   *   @ p a r a m   [ m e s s a g e ]   
   * /   
 m o d u l e . e x p o r t s . n o t E q u a l   =   f u n c t i o n   n o t E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e )   {   
     i f   ( a c t u a l   = =   e x p e c t e d )   {   
         f a i l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e ,   ' ! = ' ,   a s s e r t . n o t E q u a l ) ;   
     }   
 } ;   
   
 / /   7 .   T h e   e q u i v a l e n c e   a s s e r t i o n   t e s t s   a   d e e p   e q u a l i t y   r e l a t i o n .   
 / /   a s s e r t . d e e p E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e _ o p t ) ;   
   
 / * *   
   *   T e s t s   f o r   d e e p   e q u a l i t y .   
   *   @ p a r a m   a c t u a l   
   *   @ p a r a m   e x p e c t e d   
   *   @ p a r a m   [ m e s s a g e ]   
   * /   
 m o d u l e . e x p o r t s . d e e p E q u a l   =   f u n c t i o n   d e e p E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e )   {   
     i f   ( ! _ d e e p E q u a l ( a c t u a l ,   e x p e c t e d ,   f a l s e ) )   {   
         f a i l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e ,   ' d e e p E q u a l ' ,   a s s e r t . d e e p E q u a l ) ;   
     }   
 } ;   
   
 / * *   
   *   G e n e r a l l y   i d e n t i c a l   t o   a s s e r t . d e e p E q u a l ( )   w i t h   t w o   e x c e p t i o n s .   
   *   F i r s t ,   p r i m i t i v e   v a l u e s   a r e   c o m p a r e d   u s i n g   t h e   s t r i c t   e q u a l i t y   o p e r a t o r   (   = = =   ) .   
   *   S e c o n d ,   o b j e c t   c o m p a r i s o n s   i n c l u d e   a   s t r i c t   e q u a l i t y   c h e c k   o f   t h e i r   p r o t o t y p e s .   
   *   @ p a r a m   a c t u a l   
   *   @ p a r a m   e x p e c t e d   
   *   @ p a r a m   [ m e s s a g e ]   
   * /   
 a s s e r t . d e e p S t r i c t E q u a l   =   f u n c t i o n   d e e p S t r i c t E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e )   {   
     i f   ( ! _ d e e p E q u a l ( a c t u a l ,   e x p e c t e d ,   t r u e ) )   {   
         f a i l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e ,   ' d e e p S t r i c t E q u a l ' ,   a s s e r t . d e e p S t r i c t E q u a l ) ;   
     }   
 } ;   
   
 f u n c t i o n   _ d e e p E q u a l ( a c t u a l ,   e x p e c t e d ,   s t r i c t ,   m e m o s )   {   
     / /   7 . 1 .   A l l   i d e n t i c a l   v a l u e s   a r e   e q u i v a l e n t ,   a s   d e t e r m i n e d   b y   = = = .   
     i f   ( a c t u a l   = = =   e x p e c t e d )   {   
         r e t u r n   t r u e ;   
     }   e l s e   i f   ( a c t u a l   i n s t a n c e o f   B u f f e r   & &   e x p e c t e d   i n s t a n c e o f   B u f f e r )   {   
         r e t u r n   c o m p a r e ( a c t u a l ,   e x p e c t e d )   = = =   0 ;   
 / /   U B   S E P C I F I C   
     }   e l s e   i f   ( a c t u a l   i n s t a n c e o f   A r r a y B u f f e r   & &   e x p e c t e d   i n s t a n c e o f   A r r a y B u f f e r )   {   
             i f   ( a c t u a l . b y t e L e n g t h   ! =   e x p e c t e d . b y t e L e n g t h )   r e t u r n   f a l s e ;   
             v a r   a B u f   =   n e w   U i n t 8 A r r a y ( a c t u a l ) ,   e B u f   =   n e w   U i n t 8 A r r a y ( e x p e c t e d ) ;   
   
             f o r   ( v a r   i   =   0 ;   i   <   a B u f . l e n g t h ;   i + + )   {   
                     i f   ( a B u f [ i ]   ! = =   e B u f [ i ] )   r e t u r n   f a l s e ;   
             }   
   
             r e t u r n   t r u e ;   
     / /   7 . 2 .   I f   t h e   e x p e c t e d   v a l u e   i s   a   D a t e   o b j e c t ,   t h e   a c t u a l   v a l u e   i s   
     / /   e q u i v a l e n t   i f   i t   i s   a l s o   a   D a t e   o b j e c t   t h a t   r e f e r s   t o   t h e   s a m e   t i m e .   
     }   e l s e   i f   ( u t i l . i s D a t e ( a c t u a l )   & &   u t i l . i s D a t e ( e x p e c t e d ) )   {   
         r e t u r n   a c t u a l . g e t T i m e ( )   = = =   e x p e c t e d . g e t T i m e ( ) ;   
   
     / /   7 . 3   I f   t h e   e x p e c t e d   v a l u e   i s   a   R e g E x p   o b j e c t ,   t h e   a c t u a l   v a l u e   i s   
     / /   e q u i v a l e n t   i f   i t   i s   a l s o   a   R e g E x p   o b j e c t   w i t h   t h e   s a m e   s o u r c e   a n d   
     / /   p r o p e r t i e s   ( ` g l o b a l ` ,   ` m u l t i l i n e ` ,   ` l a s t I n d e x ` ,   ` i g n o r e C a s e ` ) .   
     }   e l s e   i f   ( u t i l . i s R e g E x p ( a c t u a l )   & &   u t i l . i s R e g E x p ( e x p e c t e d ) )   {   
         r e t u r n   a c t u a l . s o u r c e   = = =   e x p e c t e d . s o u r c e   & &   
                       a c t u a l . g l o b a l   = = =   e x p e c t e d . g l o b a l   & &   
                       a c t u a l . m u l t i l i n e   = = =   e x p e c t e d . m u l t i l i n e   & &   
                       a c t u a l . l a s t I n d e x   = = =   e x p e c t e d . l a s t I n d e x   & &   
                       a c t u a l . i g n o r e C a s e   = = =   e x p e c t e d . i g n o r e C a s e ;   
   
     / /   7 . 4 .   O t h e r   p a i r s   t h a t   d o   n o t   b o t h   p a s s   t y p e o f   v a l u e   = =   ' o b j e c t ' ,   
     / /   e q u i v a l e n c e   i s   d e t e r m i n e d   b y   = = .   
     }   e l s e   i f   ( ( a c t u a l   = = =   n u l l   | |   t y p e o f   a c t u a l   ! = =   ' o b j e c t ' )   & &   
                           ( e x p e c t e d   = = =   n u l l   | |   t y p e o f   e x p e c t e d   ! = =   ' o b j e c t ' ) )   {   
         r e t u r n   s t r i c t   ?   a c t u a l   = = =   e x p e c t e d   :   a c t u a l   = =   e x p e c t e d ;   
   
     / /   I f   b o t h   v a l u e s   a r e   i n s t a n c e s   o f   t y p e d   a r r a y s ,   w r a p   t h e i r   u n d e r l y i n g   
     / /   A r r a y B u f f e r s   i n   a   B u f f e r   e a c h   t o   i n c r e a s e   p e r f o r m a n c e   
     / /   T h i s   o p t i m i z a t i o n   r e q u i r e s   t h e   a r r a y s   t o   h a v e   t h e   s a m e   t y p e   a s   c h e c k e d   b y   
     / /   O b j e c t . p r o t o t y p e . t o S t r i n g   ( a k a   p T o S t r i n g ) .   N e v e r   p e r f o r m   b i n a r y   
     / /   c o m p a r i s o n s   f o r   F l o a t * A r r a y s ,   t h o u g h ,   s i n c e   e . g .   + 0   = = =   - 0   b u t   t h e i r   
     / /   b i t   p a t t e r n s   a r e   n o t   i d e n t i c a l .   
     }   e l s e   i f   ( A r r a y B u f f e r . i s V i e w ( a c t u a l )   & &   A r r a y B u f f e r . i s V i e w ( e x p e c t e d )   & &   
                           p T o S t r i n g ( a c t u a l )   = = =   p T o S t r i n g ( e x p e c t e d )   & &   
                           ! ( a c t u a l   i n s t a n c e o f   F l o a t 3 2 A r r a y   | |   
                               a c t u a l   i n s t a n c e o f   F l o a t 6 4 A r r a y ) )   {   
         r e t u r n   c o m p a r e ( B u f f e r . f r o m ( a c t u a l . b u f f e r ,   
                                                               a c t u a l . b y t e O f f s e t ,   
                                                               a c t u a l . b y t e L e n g t h ) ,   
                                       B u f f e r . f r o m ( e x p e c t e d . b u f f e r ,   
                                                               e x p e c t e d . b y t e O f f s e t ,   
                                                               e x p e c t e d . b y t e L e n g t h ) )   = = =   0 ;   
   
     / /   7 . 5   F o r   a l l   o t h e r   O b j e c t   p a i r s ,   i n c l u d i n g   A r r a y   o b j e c t s ,   e q u i v a l e n c e   i s   
     / /   d e t e r m i n e d   b y   h a v i n g   t h e   s a m e   n u m b e r   o f   o w n e d   p r o p e r t i e s   ( a s   v e r i f i e d   
     / /   w i t h   O b j e c t . p r o t o t y p e . h a s O w n P r o p e r t y . c a l l ) ,   t h e   s a m e   s e t   o f   k e y s   
     / /   ( a l t h o u g h   n o t   n e c e s s a r i l y   t h e   s a m e   o r d e r ) ,   e q u i v a l e n t   v a l u e s   f o r   e v e r y   
     / /   c o r r e s p o n d i n g   k e y ,   a n d   a n   i d e n t i c a l   ' p r o t o t y p e '   p r o p e r t y .   N o t e :   t h i s   
     / /   a c c o u n t s   f o r   b o t h   n a m e d   a n d   i n d e x e d   p r o p e r t i e s   o n   A r r a y s .   
     }   e l s e   {   
         m e m o s   =   m e m o s   | |   { a c t u a l :   [ ] ,   e x p e c t e d :   [ ] } ;   
   
         c o n s t   a c t u a l I n d e x   =   m e m o s . a c t u a l . i n d e x O f ( a c t u a l ) ;   
         i f   ( a c t u a l I n d e x   ! = =   - 1 )   {   
             i f   ( a c t u a l I n d e x   = = =   m e m o s . e x p e c t e d . i n d e x O f ( e x p e c t e d ) )   {   
                 r e t u r n   t r u e ;   
             }   
         }   
   
         m e m o s . a c t u a l . p u s h ( a c t u a l ) ;   
         m e m o s . e x p e c t e d . p u s h ( e x p e c t e d ) ;   
   
         r e t u r n   o b j E q u i v ( a c t u a l ,   e x p e c t e d ,   s t r i c t ,   m e m o s ) ;   
     }   
 }   
   
 f u n c t i o n   i s A r g u m e n t s ( o b j e c t )   {   
     r e t u r n   O b j e c t . p r o t o t y p e . t o S t r i n g . c a l l ( o b j e c t )   = =   ' [ o b j e c t   A r g u m e n t s ] ' ;   
 }   
   
 f u n c t i o n   o b j E q u i v ( a ,   b ,   s t r i c t ,   a c t u a l V i s i t e d O b j e c t s )   {   
     i f   ( a   = = =   n u l l   | |   a   = = =   u n d e f i n e d   | |   b   = = =   n u l l   | |   b   = = =   u n d e f i n e d )   
         r e t u r n   f a l s e ;   
     / /   i f   o n e   i s   a   p r i m i t i v e ,   t h e   o t h e r   m u s t   b e   s a m e   
     i f   ( u t i l . i s P r i m i t i v e ( a )   | |   u t i l . i s P r i m i t i v e ( b ) )   
         r e t u r n   a   = = =   b ;   
     i f   ( s t r i c t   & &   O b j e c t . g e t P r o t o t y p e O f ( a )   ! = =   O b j e c t . g e t P r o t o t y p e O f ( b ) )   
         r e t u r n   f a l s e ;   
     c o n s t   a I s A r g s   =   i s A r g u m e n t s ( a ) ;   
     c o n s t   b I s A r g s   =   i s A r g u m e n t s ( b ) ;   
     i f   ( ( a I s A r g s   & &   ! b I s A r g s )   | |   ( ! a I s A r g s   & &   b I s A r g s ) )   
         r e t u r n   f a l s e ;   
     c o n s t   k a   =   O b j e c t . k e y s ( a ) ;   
     c o n s t   k b   =   O b j e c t . k e y s ( b ) ;   
     v a r   k e y ,   i ;   
     / /   h a v i n g   t h e   s a m e   n u m b e r   o f   o w n e d   p r o p e r t i e s   ( k e y s   i n c o r p o r a t e s   
     / /   h a s O w n P r o p e r t y )   
     i f   ( k a . l e n g t h   ! = =   k b . l e n g t h )   
         r e t u r n   f a l s e ;   
     / / t h e   s a m e   s e t   o f   k e y s   ( a l t h o u g h   n o t   n e c e s s a r i l y   t h e   s a m e   o r d e r ) ,   
     k a . s o r t ( ) ;   
     k b . s o r t ( ) ;   
     / / ~ ~ ~ c h e a p   k e y   t e s t   
     f o r   ( i   =   k a . l e n g t h   -   1 ;   i   > =   0 ;   i - - )   {   
         i f   ( k a [ i ]   ! = =   k b [ i ] )   
             r e t u r n   f a l s e ;   
     }   
     / / e q u i v a l e n t   v a l u e s   f o r   e v e r y   c o r r e s p o n d i n g   k e y ,   a n d   
     / / ~ ~ ~ p o s s i b l y   e x p e n s i v e   d e e p   t e s t   
     f o r   ( i   =   k a . l e n g t h   -   1 ;   i   > =   0 ;   i - - )   {   
         k e y   =   k a [ i ] ;   
         i f   ( ! _ d e e p E q u a l ( a [ k e y ] ,   b [ k e y ] ,   s t r i c t ,   a c t u a l V i s i t e d O b j e c t s ) )   
             r e t u r n   f a l s e ;   
     }   
     r e t u r n   t r u e ;   
 }   
   
 / /   8 .   T h e   n o n - e q u i v a l e n c e   a s s e r t i o n   t e s t s   f o r   a n y   d e e p   i n e q u a l i t y .   
 / /   a s s e r t . n o t D e e p E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e _ o p t ) ;   
   
 / * *   
   *   T e s t s   f o r   a n y   d e e p   i n e q u a l i t y .   
   *   @ p a r a m   a c t u a l   
   *   @ p a r a m   e x p e c t e d   
   *   @ p a r a m   [ m e s s a g e ]   
   * /   
 m o d u l e . e x p o r t s . n o t D e e p E q u a l   =   f u n c t i o n   n o t D e e p E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e )   {   
     i f   ( _ d e e p E q u a l ( a c t u a l ,   e x p e c t e d ,   f a l s e ) )   {   
         f a i l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e ,   ' n o t D e e p E q u a l ' ,   a s s e r t . n o t D e e p E q u a l ) ;   
     }   
 } ;   
   
 a s s e r t . n o t D e e p S t r i c t E q u a l   =   n o t D e e p S t r i c t E q u a l ;   
 f u n c t i o n   n o t D e e p S t r i c t E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e )   {   
     i f   ( _ d e e p E q u a l ( a c t u a l ,   e x p e c t e d ,   t r u e ) )   {   
         f a i l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e ,   ' n o t D e e p S t r i c t E q u a l ' ,   n o t D e e p S t r i c t E q u a l ) ;   
     }   
 }   
   
   
 / /   9 .   T h e   s t r i c t   e q u a l i t y   a s s e r t i o n   t e s t s   s t r i c t   e q u a l i t y ,   a s   d e t e r m i n e d   b y   = = = .   
 / /   a s s e r t . s t r i c t E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e _ o p t ) ;   
   
 a s s e r t . s t r i c t E q u a l   =   f u n c t i o n   s t r i c t E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e )   {   
     i f   ( a c t u a l   ! = =   e x p e c t e d )   {   
         f a i l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e ,   ' = = = ' ,   a s s e r t . s t r i c t E q u a l ) ;   
     }   
 } ;   
   
 / /   1 0 .   T h e   s t r i c t   n o n - e q u a l i t y   a s s e r t i o n   t e s t s   f o r   s t r i c t   i n e q u a l i t y ,   a s   
 / /   d e t e r m i n e d   b y   ! = = .     a s s e r t . n o t S t r i c t E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e _ o p t ) ;   
   
 a s s e r t . n o t S t r i c t E q u a l   =   f u n c t i o n   n o t S t r i c t E q u a l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e )   {   
     i f   ( a c t u a l   = = =   e x p e c t e d )   {   
         f a i l ( a c t u a l ,   e x p e c t e d ,   m e s s a g e ,   ' ! = = ' ,   a s s e r t . n o t S t r i c t E q u a l ) ;   
     }   
 } ;   
   
 f u n c t i o n   e x p e c t e d E x c e p t i o n ( a c t u a l ,   e x p e c t e d )   {   
     i f   ( ! a c t u a l   | |   ! e x p e c t e d )   {   
         r e t u r n   f a l s e ;   
     }   
   
     i f   ( O b j e c t . p r o t o t y p e . t o S t r i n g . c a l l ( e x p e c t e d )   = =   ' [ o b j e c t   R e g E x p ] ' )   {   
         r e t u r n   e x p e c t e d . t e s t ( a c t u a l ) ;   
     }   
   
     t r y   {   
         i f   ( a c t u a l   i n s t a n c e o f   e x p e c t e d )   {   
             r e t u r n   t r u e ;   
         }   
     }   c a t c h   ( e )   {   
         / /   I g n o r e .     T h e   i n s t a n c e o f   c h e c k   d o e s n ' t   w o r k   f o r   a r r o w   f u n c t i o n s .   
     }   
   
     i f   ( E r r o r . i s P r o t o t y p e O f ( e x p e c t e d ) )   {   
         r e t u r n   f a l s e ;   
     }   
   
     r e t u r n   e x p e c t e d . c a l l ( { } ,   a c t u a l )   = = =   t r u e ;   
 }   
   
 f u n c t i o n   _ t r y B l o c k ( b l o c k )   {   
     v a r   e r r o r ;   
     t r y   {   
         b l o c k ( ) ;   
     }   c a t c h   ( e )   {   
         e r r o r   =   e ;   
     }   
     r e t u r n   e r r o r ;   
 }   
   
 f u n c t i o n   _ t h r o w s ( s h o u l d T h r o w ,   b l o c k ,   e x p e c t e d ,   m e s s a g e )   {   
     v a r   a c t u a l ;   
   
     i f   ( t y p e o f   b l o c k   ! = =   ' f u n c t i o n ' )   {   
         t h r o w   n e w   T y p e E r r o r ( ' " b l o c k "   a r g u m e n t   m u s t   b e   a   f u n c t i o n ' ) ;   
     }   
   
     i f   ( t y p e o f   e x p e c t e d   = = =   ' s t r i n g ' )   {   
         m e s s a g e   =   e x p e c t e d ;   
         e x p e c t e d   =   n u l l ;   
     }   
   
     a c t u a l   =   _ t r y B l o c k ( b l o c k ) ;   
   
     m e s s a g e   =   ( e x p e c t e d   & &   e x p e c t e d . n a m e   ?   '   ( '   +   e x p e c t e d . n a m e   +   ' ) . '   :   ' . ' )   +   
                         ( m e s s a g e   ?   '   '   +   m e s s a g e   :   ' . ' ) ;   
   
     i f   ( s h o u l d T h r o w   & &   ! a c t u a l )   {   
         f a i l ( a c t u a l ,   e x p e c t e d ,   ' M i s s i n g   e x p e c t e d   e x c e p t i o n '   +   m e s s a g e ) ;   
     }   
   
     c o n s t   u s e r P r o v i d e d M e s s a g e   =   t y p e o f   m e s s a g e   = = =   ' s t r i n g ' ;   
     c o n s t   i s U n w a n t e d E x c e p t i o n   =   ! s h o u l d T h r o w   & &   u t i l . i s E r r o r ( a c t u a l ) ;   
     c o n s t   i s U n e x p e c t e d E x c e p t i o n   =   ! s h o u l d T h r o w   & &   a c t u a l   & &   ! e x p e c t e d ;   
   
     i f   ( ( i s U n w a n t e d E x c e p t i o n   & &   
             u s e r P r o v i d e d M e s s a g e   & &   
             e x p e c t e d E x c e p t i o n ( a c t u a l ,   e x p e c t e d ) )   | |   
             i s U n e x p e c t e d E x c e p t i o n )   {   
         f a i l ( a c t u a l ,   e x p e c t e d ,   ' G o t   u n w a n t e d   e x c e p t i o n '   +   m e s s a g e ) ;   
     }   
   
     i f   ( ( s h o u l d T h r o w   & &   a c t u a l   & &   e x p e c t e d   & &   
             ! e x p e c t e d E x c e p t i o n ( a c t u a l ,   e x p e c t e d ) )   | |   ( ! s h o u l d T h r o w   & &   a c t u a l ) )   {   
         t h r o w   a c t u a l ;   
     }   
 }   
   
 / /   1 1 .   E x p e c t e d   t o   t h r o w   a n   e r r o r :   
 / /   a s s e r t . t h r o w s ( b l o c k ,   E r r o r _ o p t ,   m e s s a g e _ o p t ) ;   
 / * *   
   *   E x p e c t s   b l o c k   t o   t h r o w   a n   e r r o r .   e r r o r   c a n   b e   c o n s t r u c t o r ,   R e g E x p   o r   v a l i d a t i o n   f u n c t i o n .   
   *   
   *   V a l i d a t e   i n s t a n c e o f   u s i n g   c o n s t r u c t o r :   
   *   
   *             a s s e r t . t h r o w s ( f u n c t i o n ( )   {   
   *                   t h r o w   n e w   E r r o r ( " W r o n g   v a l u e " ) ;   
   *             } ,   E r r o r ) ;   
   *   
   *   V a l i d a t e   e r r o r   m e s s a g e   u s i n g   R e g E x p :   
   *   
   *             a s s e r t . t h r o w s ( f u n c t i o n ( )   {   
   *                   t h r o w   n e w   E r r o r ( " W r o n g   v a l u e " ) ;   
   *             } ,   / e r r o r / ) ;   
   *   
   *   C u s t o m   e r r o r   v a l i d a t i o n :   
   *   
   *             a s s e r t . t h r o w s (   
   *             f u n c t i o n ( )   {   
   *                   t h r o w   n e w   E r r o r ( " W r o n g   v a l u e " ) ;   
   *               } ,   
   *             f u n c t i o n ( e r r )   {   
   *                   i f   (   ( e r r   i n s t a n c e o f   E r r o r )   & &   / v a l u e / . t e s t ( e r r )   )   {   
   *                       r e t u r n   t r u e ;   
   *                   }   
   *               } ,   
   *             " u n e x p e c t e d   e r r o r "   
   *             ) ;   
   *   
   *   @ p a r a m   b l o c k   
   *   @ p a r a m   [ e r r o r ]   
   *   @ p a r a m   [ m e s s a g e ]   
   * /   
 m o d u l e . e x p o r t s . t h r o w s   =   f u n c t i o n ( b l o c k ,   / * o p t i o n a l * / e r r o r ,   / * o p t i o n a l * / m e s s a g e )   {   
     _ t h r o w s ( t r u e ,   b l o c k ,   e r r o r ,   m e s s a g e ) ;   
 } ;   
   
 / /   E X T E N S I O N !   T h i s   i s   a n n o y i n g   t o   w r i t e   o u t s i d e   t h i s   m o d u l e .   
 / * *   
   *   E x p e c t s   b l o c k   n o t   t o   t h r o w   a n   e r r o r ,   s e e   a s s e r t . t h r o w s   f o r   d e t a i l s .   
   *   @ p a r a m   b l o c k   
   *   @ p a r a m   [ e r r o r ]   
   *   @ p a r a m   [ m e s s a g e ]   
   * /   
 m o d u l e . e x p o r t s . d o e s N o t T h r o w   =   f u n c t i o n ( b l o c k ,   / * o p t i o n a l * / e r r o r ,   / * o p t i o n a l * / m e s s a g e )   {   
     _ t h r o w s ( f a l s e ,   b l o c k ,   e r r o r ,   m e s s a g e ) ;   
 } ;   
   
 / * *   
   *   T e s t s   i f   v a l u e   i s   n o t   a   f a l s e   v a l u e ,   t h r o w s   i f   i t   i s   a   t r u e   v a l u e .   U s e f u l   w h e n   t e s t i n g   t h e   f i r s t   a r g u m e n t ,   e r r o r   i n   c a l l b a c k s .   
   *   @ p a r a m   e r r   
   * /   
 m o d u l e . e x p o r t s . i f E r r o r   =   f u n c t i o n ( e r r )   {   i f   ( e r r )   { t h r o w   e r r ; } } ;   
 
 } ) ;   �  L   ��
 N O D E _ M O D U L E S / B U F F E R . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / *   e s l i n t - d i s a b l e   r e q u i r e - b u f f e r   * /   
 / * *   
   *   N o d e J S   c o m p a r t i b l e   B u f f e r   i m p l e m e n a t t i o n .   
   *   S e e   < a   h r e f = " h t t p s : / / n o d e j s . o r g / d o c s / l a t e s t / a p i / b u f f e r . h t m l " > o r i g i n a l   B u f f e r   d o u m n e t a t i o n < / a >   
   *   
   *   O n e   a d d i t i o n a l   m e t h o d   i s   a d e d d   f o r   c o n v e r t i n g   b u f f e r   c o n t e n t   t o   a n y   c o d e p a g e   ` B u f f e r . p r o t o t y p e . c p S l i c e ` :   
   *     
   *   	   l e t   a r r   =   f s . r e a d F i l e S y n c ( p a t h . j o i n ( _ _ d i r n a m e ,   ' w i n 1 2 5 1 E n c o d e d . X M L ' ) ,   { e n c o d i n g :   ' b i n a r y ' } )   
   * 	   l e t   b u f f e r   =   B u f f e r . f r o m ( a r r )   
   * 	   l e t   s t r D a t a   =   b u f f e r . c p S l i c e ( 0 ,   b u f f e r . l e n g t h ,   1 2 5 1 )   
   *   
   *   @ m o d u l e   b u f f e r   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 ' u s e   s t r i c t ' ;   
   
 c o n s t   b i n d i n g   =   p r o c e s s . b i n d i n g ( ' b u f f e r ' ) ;   
 c o n s t   {   i s A r r a y B u f f e r   }   =   p r o c e s s . b i n d i n g ( ' u t i l ' ) ;   
 c o n s t   b i n d i n g O b j   =   { } ;   
 c o n s t   i n t e r n a l U t i l   =   r e q u i r e ( ' i n t e r n a l / u t i l ' ) ;   
   
 / / O r e l .   F i x e s   f o r   S p i d e r m o n k e y   
 f u n c t i o n   g e t B u f f e r L e n g t h ( s i z e )   {   
         r e t u r n   s i z e   *   1   >   b i n d i n g . k M a x L e n g t h   ?     - 1   :   s i z e   > > >   0 ;   
 }   
   
 c l a s s   F a s t B u f f e r   e x t e n d s   U i n t 8 A r r a y   {   
     c o n s t r u c t o r ( . . . a r g s ) {   
         / / O r e l .   F i x e s   f o r   S p i d e r m o n k e y   
         i f   ( ( a r g s . l e n g t h   = = =   1 )   & &   ( t y p e o f ( a r g s [ 0 ] ) = = = ' n u m b e r ' ) )   {   
                 s u p e r ( g e t B u f f e r L e n g t h ( a r g s [ 0 ] ) )   
         }   e l s e   {   
                 s u p e r ( . . . a r g s ) ;   
         }   
     }   
 }   
   
 F a s t B u f f e r . p r o t o t y p e . c o n s t r u c t o r   =   B u f f e r ;   
 B u f f e r . p r o t o t y p e   =   F a s t B u f f e r . p r o t o t y p e ;   
   
 e x p o r t s . B u f f e r   =   B u f f e r ;   
 e x p o r t s . S l o w B u f f e r   =   S l o w B u f f e r ;   
 e x p o r t s . I N S P E C T _ M A X _ B Y T E S   =   5 0 ;   
 e x p o r t s . k M a x L e n g t h   =   b i n d i n g . k M a x L e n g t h ;   
   
 c o n s t   k F r o m E r r o r M s g   =   ' F i r s t   a r g u m e n t   m u s t   b e   a   s t r i n g ,   B u f f e r ,   '   +   
                                             ' A r r a y B u f f e r ,   A r r a y ,   o r   a r r a y - l i k e   o b j e c t . ' ;   
   
 B u f f e r . p o o l S i z e   =   8   *   1 0 2 4 ;   
 v a r   p o o l S i z e ,   p o o l O f f s e t ,   a l l o c P o o l ;   
   
   
 b i n d i n g . s e t u p B u f f e r J S ( B u f f e r . p r o t o t y p e ,   b i n d i n g O b j ) ;   
   
 / /   | b i n d i n g . z e r o F i l l |   c a n   b e   u n d e f i n e d   w h e n   r u n n i n g   i n s i d e   a n   i s o l a t e   w h e r e   w e   
 / /   d o   n o t   o w n   t h e   A r r a y B u f f e r   a l l o c a t o r .     Z e r o   f i l l   i s   a l w a y s   o n   i n   t h a t   c a s e .   
 c o n s t   z e r o F i l l   =   b i n d i n g O b j . z e r o F i l l   | |   [ 0 ] ;   
   
 f u n c t i o n   c r e a t e U n s a f e B u f f e r ( s i z e )   {   
     r e t u r n   n e w   F a s t B u f f e r ( c r e a t e U n s a f e A r r a y B u f f e r ( s i z e ) ) ;   
 }   
   
 f u n c t i o n   c r e a t e U n s a f e A r r a y B u f f e r ( s i z e )   {   
     z e r o F i l l [ 0 ]   =   0 ;   
     t r y   {   
         / / O r e l .   F i x e s   f o r   S p i d e r m o n k e y   
         r e t u r n   n e w   A r r a y B u f f e r ( g e t B u f f e r L e n g t h ( s i z e ) ) ;   
     }   f i n a l l y   {   
         z e r o F i l l [ 0 ]   =   1 ;   
     }   
 }   
   
 f u n c t i o n   c r e a t e P o o l ( )   {   
     p o o l S i z e   =   B u f f e r . p o o l S i z e ;   
     a l l o c P o o l   =   c r e a t e U n s a f e A r r a y B u f f e r ( p o o l S i z e ) ;   
     p o o l O f f s e t   =   0 ;   
 }   
 c r e a t e P o o l ( ) ;   
   
   
 f u n c t i o n   a l i g n P o o l ( )   {   
     / /   E n s u r e   a l i g n e d   s l i c e s   
     i f   ( p o o l O f f s e t   &   0 x 7 )   {   
         p o o l O f f s e t   | =   0 x 7 ;   
         p o o l O f f s e t + + ;   
     }   
 }   
   
 / * *   
   *   T h e   B u f f e r ( )   c o n s t r u t o r   i s   " s o f t   d e p r e c a t e d "   . . .   t h a t   i s ,   i t   i s   d e p r e c a t e d   
   *   i n   t h e   d o c u m e n t a t i o n   a n d   s h o u l d   n o t   b e   u s e d   m o v i n g   f o r w a r d .   R a t h e r ,   
   *   d e v e l o p e r s   s h o u l d   u s e   o n e   o f   t h e   t h r e e   n e w   f a c t o r y   A P I s :   B u f f e r . f r o m ( ) ,   
   *   B u f f e r . a l l o c U n s a f e ( )   o r   B u f f e r . a l l o c ( )   b a s e d   o n   t h e i r   s p e c i f i c   n e e d s .   T h e r e   
   *   i s   n o   h a r d   d e p r e c a t i o n   b e c a u s e   o f   t h e   e x t e n t   t o   w h i c h   t h e   B u f f e r   c o n s t r u c t o r   
   *   i s   u s e d   i n   t h e   e c o s y s t e m   c u r r e n t l y   - -   a   h a r d   d e p r e c a t i o n   w o u l d   i n t r o d u c e   t o o   
   *   m u c h   b r e a k a g e   a t   t h i s   t i m e .   I t ' s   n o t   l i k e l y   t h a t   t h e   B u f f e r   c o n s t r u c t o r s   
   *   w o u l d   e v e r   a c t u a l l y   b e   r e m o v e d .   
   * * /   
 v a r   n e w B u f f e r W a r n e d   =   f a l s e ;   
 f u n c t i o n   B u f f e r ( a r g ,   e n c o d i n g O r O f f s e t ,   l e n g t h )   {   
     i f   ( ! n e w . t a r g e t   & &   ! n e w B u f f e r W a r n e d )   {   
         n e w B u f f e r W a r n e d   =   t r u e ;   
         p r o c e s s . e m i t W a r n i n g (   
             ' U s i n g   B u f f e r   w i t h o u t   ` n e w `   w i l l   s o o n   s t o p   w o r k i n g .   '   +   
             ' U s e   ` n e w   B u f f e r ( ) ` ,   o r   p r e f e r a b l y   '   +   
             ' ` B u f f e r . f r o m ( ) ` ,   ` B u f f e r . a l l o c U n s a f e ( ) `   o r   ` B u f f e r . a l l o c ( ) `   i n s t e a d . ' ,   
             ' D e p r e c a t i o n W a r n i n g '   
         ) ;   
     }   
     / /   C o m m o n   c a s e .   
     i f   ( t y p e o f   a r g   = = =   ' n u m b e r ' )   {   
         i f   ( t y p e o f   e n c o d i n g O r O f f s e t   = = =   ' s t r i n g ' )   {   
             t h r o w   n e w   E r r o r (   
                 ' I f   e n c o d i n g   i s   s p e c i f i e d   t h e n   t h e   f i r s t   a r g u m e n t   m u s t   b e   a   s t r i n g '   
             ) ;   
         }   
         r e t u r n   B u f f e r . a l l o c U n s a f e ( a r g ) ;   
     }   
     r e t u r n   B u f f e r . f r o m ( a r g ,   e n c o d i n g O r O f f s e t ,   l e n g t h ) ;   
 }   
   
 / * *   
   *   F u n c t i o n a l l y   e q u i v a l e n t   t o   B u f f e r ( a r g ,   e n c o d i n g )   b u t   t h r o w s   a   T y p e E r r o r   
   *   i f   v a l u e   i s   a   n u m b e r .   
   *   B u f f e r . f r o m ( s t r [ ,   e n c o d i n g ] )   
   *   B u f f e r . f r o m ( a r r a y )   
   *   B u f f e r . f r o m ( b u f f e r )   
   *   B u f f e r . f r o m ( a r r a y B u f f e r [ ,   b y t e O f f s e t [ ,   l e n g t h ] ] )   
   * * /   
 B u f f e r . f r o m   =   f u n c t i o n ( v a l u e ,   e n c o d i n g O r O f f s e t ,   l e n g t h )   {   
     i f   ( t y p e o f   v a l u e   = = =   ' n u m b e r ' )   
         t h r o w   n e w   T y p e E r r o r ( ' " v a l u e "   a r g u m e n t   m u s t   n o t   b e   a   n u m b e r ' ) ;   
   
     i f   ( v a l u e   i n s t a n c e o f   A r r a y B u f f e r )   
         r e t u r n   f r o m A r r a y B u f f e r ( v a l u e ,   e n c o d i n g O r O f f s e t ,   l e n g t h ) ;   
   
     i f   ( t y p e o f   v a l u e   = = =   ' s t r i n g ' )   
         r e t u r n   f r o m S t r i n g ( v a l u e ,   e n c o d i n g O r O f f s e t ) ;   
   
     r e t u r n   f r o m O b j e c t ( v a l u e ) ;   
 } ;   
   
 O b j e c t . s e t P r o t o t y p e O f ( B u f f e r ,   U i n t 8 A r r a y ) ;   
   
 f u n c t i o n   a s s e r t S i z e ( s i z e )   {   
     l e t   e r r   =   n u l l ;   
   
     i f   ( t y p e o f   s i z e   ! = =   ' n u m b e r ' )   
         e r r   =   n e w   T y p e E r r o r ( ' " s i z e "   a r g u m e n t   m u s t   b e   a   n u m b e r ' ) ;   
     e l s e   i f   ( s i z e   <   0 )   
         e r r   =   n e w   R a n g e E r r o r ( ' " s i z e "   a r g u m e n t   m u s t   n o t   b e   n e g a t i v e ' ) ;   
   
     i f   ( e r r )   {   
         / /   T h e   f o l l o w i n g   h i d e s   t h e   ' a s s e r t S i z e '   m e t h o d   f r o m   t h e   
         / /   c a l l s t a c k .   T h i s   i s   d o n e   s i m p l y   t o   h i d e   t h e   i n t e r n a l   
         / /   d e t a i l s   o f   t h e   i m p l e m e n t a t i o n   f r o m   b l e e d i n g   o u t   t o   u s e r s .   
 	 i f   ( E r r o r . c a p t u r e S t a c k T r a c e )   {   
 	 	 / /   C h r o m e   a n d   N o d e J S   
 	 	 E r r o r . c a p t u r e S t a c k T r a c e ( e r r ,   a s s e r t S i z e ) ;   
 	 } 	   
   
         t h r o w   e r r ;   
     }   
 }   
   
 / * *   
   *   C r e a t e s   a   n e w   f i l l e d   B u f f e r   i n s t a n c e .   
   *   a l l o c ( s i z e [ ,   f i l l [ ,   e n c o d i n g ] ] )   
   * * /   
 B u f f e r . a l l o c   =   f u n c t i o n ( s i z e ,   f i l l ,   e n c o d i n g )   {   
     a s s e r t S i z e ( s i z e ) ;   
     i f   ( s i z e   >   0   & &   f i l l   ! = =   u n d e f i n e d )   {   
         / /   S i n c e   w e   a r e   f i l l i n g   a n y w a y ,   d o n ' t   z e r o   f i l l   i n i t i a l l y .   
         / /   O n l y   p a y   a t t e n t i o n   t o   e n c o d i n g   i f   i t ' s   a   s t r i n g .   T h i s   
         / /   p r e v e n t s   a c c i d e n t a l l y   s e n d i n g   i n   a   n u m b e r   t h a t   w o u l d   
         / /   b e   i n t e r p r e t t e d   a s   a   s t a r t   o f f s e t .   
         i f   ( t y p e o f   e n c o d i n g   ! = =   ' s t r i n g ' )   
             e n c o d i n g   =   u n d e f i n e d ;   
         r e t u r n   c r e a t e U n s a f e B u f f e r ( s i z e ) . f i l l ( f i l l ,   e n c o d i n g ) ;   
     }   
     r e t u r n   n e w   F a s t B u f f e r ( s i z e ) ;   
 } ;   
   
 / * *   
   *   E q u i v a l e n t   t o   B u f f e r ( n u m ) ,   b y   d e f a u l t   c r e a t e s   a   n o n - z e r o - f i l l e d   B u f f e r   
   *   i n s t a n c e .   I f   ` - - z e r o - f i l l - b u f f e r s `   i s   s e t ,   w i l l   z e r o - f i l l   t h e   b u f f e r .   
   * * /   
 B u f f e r . a l l o c U n s a f e   =   f u n c t i o n ( s i z e )   {   
     a s s e r t S i z e ( s i z e ) ;   
     r e t u r n   a l l o c a t e ( s i z e ) ;   
 } ;   
   
 / * *   
   *   E q u i v a l e n t   t o   S l o w B u f f e r ( n u m ) ,   b y   d e f a u l t   c r e a t e s   a   n o n - z e r o - f i l l e d   
   *   B u f f e r   i n s t a n c e   t h a t   i s   n o t   a l l o c a t e d   o f f   t h e   p r e - i n i t i a l i z e d   p o o l .   
   *   I f   ` - - z e r o - f i l l - b u f f e r s `   i s   s e t ,   w i l l   z e r o - f i l l   t h e   b u f f e r .   
   * * /   
 B u f f e r . a l l o c U n s a f e S l o w   =   f u n c t i o n ( s i z e )   {   
     a s s e r t S i z e ( s i z e ) ;   
     r e t u r n   c r e a t e U n s a f e B u f f e r ( s i z e ) ;   
 } ;   
   
 / /   I f   - - z e r o - f i l l - b u f f e r s   c o m m a n d   l i n e   a r g u m e n t   i s   s e t ,   a   z e r o - f i l l e d   
 / /   b u f f e r   i s   r e t u r n e d .   
 f u n c t i o n   S l o w B u f f e r ( l e n g t h )   {   
     i f   ( + l e n g t h   ! =   l e n g t h )   
         l e n g t h   =   0 ;   
     r e t u r n   c r e a t e U n s a f e B u f f e r ( + l e n g t h ) ;   
 }   
   
 O b j e c t . s e t P r o t o t y p e O f ( S l o w B u f f e r . p r o t o t y p e ,   U i n t 8 A r r a y . p r o t o t y p e ) ;   
 O b j e c t . s e t P r o t o t y p e O f ( S l o w B u f f e r ,   U i n t 8 A r r a y ) ;   
   
   
 f u n c t i o n   a l l o c a t e ( s i z e )   {   
     i f   ( s i z e   < =   0 )   {   
         r e t u r n   n e w   F a s t B u f f e r ( ) ;   
     }   
     i f   ( s i z e   <   ( B u f f e r . p o o l S i z e   > > >   1 ) )   {   
         i f   ( s i z e   >   ( p o o l S i z e   -   p o o l O f f s e t ) )   
             c r e a t e P o o l ( ) ;   
         v a r   b   =   n e w   F a s t B u f f e r ( a l l o c P o o l ,   p o o l O f f s e t ,   s i z e ) ;   
         p o o l O f f s e t   + =   s i z e ;   
         a l i g n P o o l ( ) ;   
         r e t u r n   b ;   
     }   e l s e   {   
         r e t u r n   c r e a t e U n s a f e B u f f e r ( s i z e ) ;   
     }   
 }   
   
   
 f u n c t i o n   f r o m S t r i n g ( s t r i n g ,   e n c o d i n g )   {   
     i f   ( t y p e o f   e n c o d i n g   ! = =   ' s t r i n g '   | |   e n c o d i n g   = = =   ' ' )   
         e n c o d i n g   =   ' u t f 8 ' ;   
   
     i f   ( ! B u f f e r . i s E n c o d i n g ( e n c o d i n g ) )   
         t h r o w   n e w   T y p e E r r o r ( ' " e n c o d i n g "   m u s t   b e   a   v a l i d   s t r i n g   e n c o d i n g ' ) ;   
   
     i f   ( s t r i n g . l e n g t h   = = =   0 )   
         r e t u r n   n e w   F a s t B u f f e r ( ) ;   
   
     v a r   l e n g t h   =   b y t e L e n g t h ( s t r i n g ,   e n c o d i n g ) ;   
   
     i f   ( l e n g t h   > =   ( B u f f e r . p o o l S i z e   > > >   1 ) )   
         r e t u r n   b i n d i n g . c r e a t e F r o m S t r i n g ( s t r i n g ,   e n c o d i n g ) ;   
   
     i f   ( l e n g t h   >   ( p o o l S i z e   -   p o o l O f f s e t ) )   
         c r e a t e P o o l ( ) ;   
     v a r   b   =   n e w   F a s t B u f f e r ( a l l o c P o o l ,   p o o l O f f s e t ,   l e n g t h ) ;   
     v a r   a c t u a l   =   b . w r i t e ( s t r i n g ,   e n c o d i n g ) ;   
     i f   ( a c t u a l   ! = =   l e n g t h )   {   
         / /   b y t e L e n g t h ( )   m a y   o v e r e s t i m a t e .   T h a t  s   a   r a r e   c a s e ,   t h o u g h .   
         b   =   n e w   F a s t B u f f e r ( a l l o c P o o l ,   p o o l O f f s e t ,   a c t u a l ) ;   
     }   
     p o o l O f f s e t   + =   a c t u a l ;   
     a l i g n P o o l ( ) ;   
     r e t u r n   b ;   
 }   
   
 f u n c t i o n   f r o m A r r a y L i k e ( o b j )   {   
     c o n s t   l e n g t h   =   o b j . l e n g t h ;   
     c o n s t   b   =   a l l o c a t e ( l e n g t h ) ;   
     f o r   ( v a r   i   =   0 ;   i   <   l e n g t h ;   i + + )   
         b [ i ]   =   o b j [ i ] ;   
     r e t u r n   b ;   
 }   
   
 f u n c t i o n   f r o m A r r a y B u f f e r ( o b j ,   b y t e O f f s e t ,   l e n g t h )   {   
     i f   ( ! i s A r r a y B u f f e r ( o b j ) )   
         t h r o w   n e w   T y p e E r r o r ( ' a r g u m e n t   i s   n o t   a n   A r r a y B u f f e r ' ) ;   
   
     b y t e O f f s e t   > > > =   0 ;   
   
     c o n s t   m a x L e n g t h   =   o b j . b y t e L e n g t h   -   b y t e O f f s e t ;   
   
     i f   ( m a x L e n g t h   <   0 )   
         t h r o w   n e w   R a n g e E r r o r ( " ' o f f s e t '   i s   o u t   o f   b o u n d s " ) ;   
   
     i f   ( l e n g t h   = = =   u n d e f i n e d )   {   
         l e n g t h   =   m a x L e n g t h ;   
     }   e l s e   {   
         l e n g t h   > > > =   0 ;   
         i f   ( l e n g t h   >   m a x L e n g t h )   
             t h r o w   n e w   R a n g e E r r o r ( " ' l e n g t h '   i s   o u t   o f   b o u n d s " ) ;   
     }   
   
     r e t u r n   n e w   F a s t B u f f e r ( o b j ,   b y t e O f f s e t ,   l e n g t h ) ;   
 }   
   
 f u n c t i o n   f r o m O b j e c t ( o b j )   {   
     i f   ( o b j   i n s t a n c e o f   B u f f e r )   {   
         c o n s t   b   =   a l l o c a t e ( o b j . l e n g t h ) ;   
   
         i f   ( b . l e n g t h   = = =   0 )   
             r e t u r n   b ;   
   
         o b j . c o p y ( b ,   0 ,   0 ,   o b j . l e n g t h ) ;   
         r e t u r n   b ;   
     }   
   
     i f   ( o b j )   {   
         i f   ( o b j . b u f f e r   i n s t a n c e o f   A r r a y B u f f e r   | |   ' l e n g t h '   i n   o b j )   {   
             i f   ( t y p e o f   o b j . l e n g t h   ! = =   ' n u m b e r '   | |   o b j . l e n g t h   ! = =   o b j . l e n g t h )   {   
                 r e t u r n   n e w   F a s t B u f f e r ( ) ;   
             }   
             r e t u r n   f r o m A r r a y L i k e ( o b j ) ;   
         }   
   
         i f   ( o b j . t y p e   = = =   ' B u f f e r '   & &   A r r a y . i s A r r a y ( o b j . d a t a ) )   {   
             r e t u r n   f r o m A r r a y L i k e ( o b j . d a t a ) ;   
         }   
     }   
   
     t h r o w   n e w   T y p e E r r o r ( k F r o m E r r o r M s g ) ;   
 }   
   
   
 / /   S t a t i c   m e t h o d s   
   
 B u f f e r . i s B u f f e r   =   f u n c t i o n   i s B u f f e r ( b )   {   
     r e t u r n   b   i n s t a n c e o f   B u f f e r ;   
 } ;   
   
   
 B u f f e r . c o m p a r e   =   f u n c t i o n   c o m p a r e ( a ,   b )   {   
     i f   ( ! ( a   i n s t a n c e o f   B u f f e r )   | |   
             ! ( b   i n s t a n c e o f   B u f f e r ) )   {   
         t h r o w   n e w   T y p e E r r o r ( ' A r g u m e n t s   m u s t   b e   B u f f e r s ' ) ;   
     }   
   
     i f   ( a   = = =   b )   {   
         r e t u r n   0 ;   
     }   
   
     r e t u r n   b i n d i n g . c o m p a r e ( a ,   b ) ;   
 } ;   
   
   
 B u f f e r . i s E n c o d i n g   =   f u n c t i o n ( e n c o d i n g )   {   
     r e t u r n   t y p e o f   e n c o d i n g   = = =   ' s t r i n g '   & &   
                   t y p e o f   i n t e r n a l U t i l . n o r m a l i z e E n c o d i n g ( e n c o d i n g )   = = =   ' s t r i n g ' ;   
 } ;   
 B u f f e r [ i n t e r n a l U t i l . k I s E n c o d i n g S y m b o l ]   =   B u f f e r . i s E n c o d i n g ;   
   
 B u f f e r . c o n c a t   =   f u n c t i o n ( l i s t ,   l e n g t h )   {   
     v a r   i ;   
     i f   ( ! A r r a y . i s A r r a y ( l i s t ) )   
         t h r o w   n e w   T y p e E r r o r ( ' " l i s t "   a r g u m e n t   m u s t   b e   a n   A r r a y   o f   B u f f e r s ' ) ;   
   
     i f   ( l i s t . l e n g t h   = = =   0 )   
         r e t u r n   n e w   F a s t B u f f e r ( ) ;   
   
     i f   ( l e n g t h   = = =   u n d e f i n e d )   {   
         l e n g t h   =   0 ;   
         f o r   ( i   =   0 ;   i   <   l i s t . l e n g t h ;   i + + )   
             l e n g t h   + =   l i s t [ i ] . l e n g t h ;   
     }   e l s e   {   
         l e n g t h   =   l e n g t h   > > >   0 ;   
     }   
   
     v a r   b u f f e r   =   B u f f e r . a l l o c U n s a f e ( l e n g t h ) ;   
     v a r   p o s   =   0 ;   
     f o r   ( i   =   0 ;   i   <   l i s t . l e n g t h ;   i + + )   {   
         v a r   b u f   =   l i s t [ i ] ;   
         i f   ( ! B u f f e r . i s B u f f e r ( b u f ) )   
             t h r o w   n e w   T y p e E r r o r ( ' " l i s t "   a r g u m e n t   m u s t   b e   a n   A r r a y   o f   B u f f e r s ' ) ;   
         b u f . c o p y ( b u f f e r ,   p o s ) ;   
         p o s   + =   b u f . l e n g t h ;   
     }   
   
     r e t u r n   b u f f e r ;   
 } ;   
   
   
 f u n c t i o n   b a s e 6 4 B y t e L e n g t h ( s t r ,   b y t e s )   {   
     / /   H a n d l e   p a d d i n g   
     i f   ( s t r . c h a r C o d e A t ( b y t e s   -   1 )   = = =   0 x 3 D )   
         b y t e s - - ;   
     i f   ( b y t e s   >   1   & &   s t r . c h a r C o d e A t ( b y t e s   -   1 )   = = =   0 x 3 D )   
         b y t e s - - ;   
   
     / /   B a s e 6 4   r a t i o :   3 / 4   
     r e t u r n   ( b y t e s   *   3 )   > > >   2 ;   
 }   
   
   
 f u n c t i o n   b y t e L e n g t h ( s t r i n g ,   e n c o d i n g )   {   
     i f   ( t y p e o f   s t r i n g   ! = =   ' s t r i n g ' )   {   
         i f   ( A r r a y B u f f e r . i s V i e w ( s t r i n g )   | |   s t r i n g   i n s t a n c e o f   A r r a y B u f f e r )   
             r e t u r n   s t r i n g . b y t e L e n g t h ;   
   
         s t r i n g   =   ' '   +   s t r i n g ;   
     }   
   
     v a r   l e n   =   s t r i n g . l e n g t h ;   
     i f   ( l e n   = = =   0 )   
         r e t u r n   0 ;   
   
     / /   U s e   a   f o r   l o o p   t o   a v o i d   r e c u r s i o n   
     v a r   l o w e r e d C a s e   =   f a l s e ;   
     f o r   ( ; ; )   {   
         s w i t c h   ( e n c o d i n g )   {   
             c a s e   ' a s c i i ' :   
             c a s e   ' l a t i n 1 ' :   
             c a s e   ' b i n a r y ' :   
                 r e t u r n   l e n ;   
   
             c a s e   ' u t f 8 ' :   
             c a s e   ' u t f - 8 ' :   
             c a s e   u n d e f i n e d :   
                 r e t u r n   b i n d i n g . b y t e L e n g t h U t f 8 ( s t r i n g ) ;   
   
             c a s e   ' u c s 2 ' :   
             c a s e   ' u c s - 2 ' :   
             c a s e   ' u t f 1 6 l e ' :   
             c a s e   ' u t f - 1 6 l e ' :   
                 r e t u r n   l e n   *   2 ;   
   
             c a s e   ' h e x ' :   
                 r e t u r n   l e n   > > >   1 ;   
   
             c a s e   ' b a s e 6 4 ' :   
                 r e t u r n   b a s e 6 4 B y t e L e n g t h ( s t r i n g ,   l e n ) ;   
   
             d e f a u l t :   
                 / /   T h e   C + +   b i n d i n g   d e f a u l t e d   t o   U T F 8 ,   w e   s h o u l d   t o o .   
                 i f   ( l o w e r e d C a s e )   
                     r e t u r n   b i n d i n g . b y t e L e n g t h U t f 8 ( s t r i n g ) ;   
   
                 e n c o d i n g   =   ( ' '   +   e n c o d i n g ) . t o L o w e r C a s e ( ) ;   
                 l o w e r e d C a s e   =   t r u e ;   
         }   
     }   
 }   
   
 B u f f e r . b y t e L e n g t h   =   b y t e L e n g t h ;   
   
   
 / /   F o r   b a c k w a r d s   c o m p a t i b i l i t y .   
 O b j e c t . d e f i n e P r o p e r t y ( B u f f e r . p r o t o t y p e ,   ' p a r e n t ' ,   {   
     e n u m e r a b l e :   t r u e ,   
     g e t :   f u n c t i o n ( )   {   
         i f   ( ! ( t h i s   i n s t a n c e o f   B u f f e r ) )   
             r e t u r n   u n d e f i n e d ;   
         i f   ( t h i s . b y t e L e n g t h   = = =   0   | |   
                 t h i s . b y t e L e n g t h   = = =   t h i s . b u f f e r . b y t e L e n g t h )   {   
             r e t u r n   u n d e f i n e d ;   
         }   
         r e t u r n   t h i s . b u f f e r ;   
     }   
 } ) ;   
 O b j e c t . d e f i n e P r o p e r t y ( B u f f e r . p r o t o t y p e ,   ' o f f s e t ' ,   {   
     e n u m e r a b l e :   t r u e ,   
     g e t :   f u n c t i o n ( )   {   
         i f   ( ! ( t h i s   i n s t a n c e o f   B u f f e r ) )   
             r e t u r n   u n d e f i n e d ;   
         r e t u r n   t h i s . b y t e O f f s e t ;   
     }   
 } ) ;   
   
   
 f u n c t i o n   s l o w T o S t r i n g ( e n c o d i n g ,   s t a r t ,   e n d )   {   
     v a r   l o w e r e d C a s e   =   f a l s e ;   
   
     / /   N o   n e e d   t o   v e r i f y   t h a t   " t h i s . l e n g t h   < =   M A X _ U I N T 3 2 "   s i n c e   i t ' s   a   r e a d - o n l y   
     / /   p r o p e r t y   o f   a   t y p e d   a r r a y .   
   
     / /   T h i s   b e h a v e s   n e i t h e r   l i k e   S t r i n g   n o r   U i n t 8 A r r a y   i n   t h a t   w e   s e t   s t a r t / e n d   
     / /   t o   t h e i r   u p p e r / l o w e r   b o u n d s   i f   t h e   v a l u e   p a s s e d   i s   o u t   o f   r a n g e .   
     / /   u n d e f i n e d   i s   h a n d l e d   s p e c i a l l y   a s   p e r   E C M A - 2 6 2   6 t h   E d i t i o n ,   
     / /   S e c t i o n   1 3 . 3 . 3 . 7   R u n t i m e   S e m a n t i c s :   K e y e d B i n d i n g I n i t i a l i z a t i o n .   
     i f   ( s t a r t   = = =   u n d e f i n e d   | |   s t a r t   <   0 )   
         s t a r t   =   0 ;   
     / /   R e t u r n   e a r l y   i f   s t a r t   >   t h i s . l e n g t h .   D o n e   h e r e   t o   p r e v e n t   p o t e n t i a l   u i n t 3 2   
     / /   c o e r c i o n   f a i l   b e l o w .   
     i f   ( s t a r t   >   t h i s . l e n g t h )   
         r e t u r n   ' ' ;   
   
     i f   ( e n d   = = =   u n d e f i n e d   | |   e n d   >   t h i s . l e n g t h )   
         e n d   =   t h i s . l e n g t h ;   
   
     i f   ( e n d   < =   0 )   
         r e t u r n   ' ' ;   
   
     / /   F o r c e   c o e r s i o n   t o   u i n t 3 2 .   T h i s   w i l l   a l s o   c o e r c e   f a l s e y / N a N   v a l u e s   t o   0 .   
     e n d   > > > =   0 ;   
     s t a r t   > > > =   0 ;   
   
     i f   ( e n d   < =   s t a r t )   
         r e t u r n   ' ' ;   
   
     i f   ( ! e n c o d i n g )   e n c o d i n g   =   ' u t f 8 ' ;   
   
     w h i l e   ( t r u e )   {   
         s w i t c h   ( e n c o d i n g )   {   
             c a s e   ' h e x ' :   
                 r e t u r n   t h i s . h e x S l i c e ( s t a r t ,   e n d ) ;   
   
             c a s e   ' u t f 8 ' :   
             c a s e   ' u t f - 8 ' :   
                 r e t u r n   t h i s . u t f 8 S l i c e ( s t a r t ,   e n d ) ;   
   
             c a s e   ' a s c i i ' :   
                 r e t u r n   t h i s . a s c i i S l i c e ( s t a r t ,   e n d ) ;   
   
             c a s e   ' l a t i n 1 ' :   
             c a s e   ' b i n a r y ' :   
                 r e t u r n   t h i s . l a t i n 1 S l i c e ( s t a r t ,   e n d ) ;   
   
             c a s e   ' b a s e 6 4 ' :   
                 r e t u r n   t h i s . b a s e 6 4 S l i c e ( s t a r t ,   e n d ) ;   
   
             c a s e   ' u c s 2 ' :   
             c a s e   ' u c s - 2 ' :   
             c a s e   ' u t f 1 6 l e ' :   
             c a s e   ' u t f - 1 6 l e ' :   
                 r e t u r n   t h i s . u c s 2 S l i c e ( s t a r t ,   e n d ) ;   
   
             d e f a u l t :   
                 i f   ( l o w e r e d C a s e )   
                     t h r o w   n e w   T y p e E r r o r ( ' U n k n o w n   e n c o d i n g :   '   +   e n c o d i n g ) ;   
                 e n c o d i n g   =   ( e n c o d i n g   +   ' ' ) . t o L o w e r C a s e ( ) ;   
                 l o w e r e d C a s e   =   t r u e ;   
         }   
     }   
 }   
   
   
 B u f f e r . p r o t o t y p e . t o S t r i n g   =   f u n c t i o n ( )   {   
     l e t   r e s u l t ;   
     i f   ( a r g u m e n t s . l e n g t h   = = =   0 )   {   
         r e s u l t   =   t h i s . u t f 8 S l i c e ( 0 ,   t h i s . l e n g t h ) ;   
     }   e l s e   {   
         r e s u l t   =   s l o w T o S t r i n g . a p p l y ( t h i s ,   a r g u m e n t s ) ;   
     }   
     i f   ( r e s u l t   = = =   u n d e f i n e d )   
         t h r o w   n e w   E r r o r ( ' " t o S t r i n g ( ) "   f a i l e d ' ) ;   
     r e t u r n   r e s u l t ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . e q u a l s   =   f u n c t i o n   e q u a l s ( b )   {   
     i f   ( ! ( b   i n s t a n c e o f   B u f f e r ) )   
         t h r o w   n e w   T y p e E r r o r ( ' A r g u m e n t   m u s t   b e   a   B u f f e r ' ) ;   
   
     i f   ( t h i s   = = =   b )   
         r e t u r n   t r u e ;   
   
     r e t u r n   b i n d i n g . c o m p a r e ( t h i s ,   b )   = = =   0 ;   
 } ;   
   
   
 / /   O v e r r i d e   h o w   b u f f e r s   a r e   p r e s e n t e d   b y   u t i l . i n s p e c t ( ) .   
 B u f f e r . p r o t o t y p e [ i n t e r n a l U t i l . i n s p e c t S y m b o l ]   =   f u n c t i o n   i n s p e c t ( )   {   
     v a r   s t r   =   ' ' ;   
     v a r   m a x   =   e x p o r t s . I N S P E C T _ M A X _ B Y T E S ;   
     i f   ( t h i s . l e n g t h   >   0 )   {   
         s t r   =   t h i s . t o S t r i n g ( ' h e x ' ,   0 ,   m a x ) . m a t c h ( / . { 2 } / g ) . j o i n ( '   ' ) ;   
         i f   ( t h i s . l e n g t h   >   m a x )   
             s t r   + =   '   . . .   ' ;   
     }   
     r e t u r n   ' < '   +   t h i s . c o n s t r u c t o r . n a m e   +   '   '   +   s t r   +   ' > ' ;   
 } ;   
 B u f f e r . p r o t o t y p e . i n s p e c t   =   B u f f e r . p r o t o t y p e [ i n t e r n a l U t i l . i n s p e c t S y m b o l ] ;   
   
 B u f f e r . p r o t o t y p e . c o m p a r e   =   f u n c t i o n   c o m p a r e ( t a r g e t ,   
                                                                                         s t a r t ,   
                                                                                         e n d ,   
                                                                                         t h i s S t a r t ,   
                                                                                         t h i s E n d )   {   
   
     i f   ( ! ( t a r g e t   i n s t a n c e o f   B u f f e r ) )   
         t h r o w   n e w   T y p e E r r o r ( ' A r g u m e n t   m u s t   b e   a   B u f f e r ' ) ;   
   
     i f   ( s t a r t   = = =   u n d e f i n e d )   
         s t a r t   =   0 ;   
     i f   ( e n d   = = =   u n d e f i n e d )   
         e n d   =   t a r g e t   ?   t a r g e t . l e n g t h   :   0 ;   
     i f   ( t h i s S t a r t   = = =   u n d e f i n e d )   
         t h i s S t a r t   =   0 ;   
     i f   ( t h i s E n d   = = =   u n d e f i n e d )   
         t h i s E n d   =   t h i s . l e n g t h ;   
   
     i f   ( s t a r t   <   0   | |   
             e n d   >   t a r g e t . l e n g t h   | |   
             t h i s S t a r t   <   0   | |   
             t h i s E n d   >   t h i s . l e n g t h )   {   
         t h r o w   n e w   R a n g e E r r o r ( ' o u t   o f   r a n g e   i n d e x ' ) ;   
     }   
   
     i f   ( t h i s S t a r t   > =   t h i s E n d   & &   s t a r t   > =   e n d )   
         r e t u r n   0 ;   
     i f   ( t h i s S t a r t   > =   t h i s E n d )   
         r e t u r n   - 1 ;   
     i f   ( s t a r t   > =   e n d )   
         r e t u r n   1 ;   
   
     s t a r t   > > > =   0 ;   
     e n d   > > > =   0 ;   
     t h i s S t a r t   > > > =   0 ;   
     t h i s E n d   > > > =   0 ;   
   
     r e t u r n   b i n d i n g . c o m p a r e O f f s e t ( t h i s ,   t a r g e t ,   s t a r t ,   t h i s S t a r t ,   e n d ,   t h i s E n d ) ;   
 } ;   
   
   
 / /   F i n d s   e i t h e r   t h e   f i r s t   i n d e x   o f   ` v a l `   i n   ` b u f f e r `   a t   o f f s e t   > =   ` b y t e O f f s e t ` ,   
 / /   O R   t h e   l a s t   i n d e x   o f   ` v a l `   i n   ` b u f f e r `   a t   o f f s e t   < =   ` b y t e O f f s e t ` .   
 / /   
 / /   A r g u m e n t s :   
 / /   -   b u f f e r   -   a   B u f f e r   t o   s e a r c h   
 / /   -   v a l   -   a   s t r i n g ,   B u f f e r ,   o r   n u m b e r   
 / /   -   b y t e O f f s e t   -   a n   i n d e x   i n t o   ` b u f f e r ` ;   w i l l   b e   c l a m p e d   t o   a n   i n t 3 2   
 / /   -   e n c o d i n g   -   a n   o p t i o n a l   e n c o d i n g ,   r e l e v a n t   i s   v a l   i s   a   s t r i n g   
 / /   -   d i r   -   t r u e   f o r   i n d e x O f ,   f a l s e   f o r   l a s t I n d e x O f   
 f u n c t i o n   b i d i r e c t i o n a l I n d e x O f ( b u f f e r ,   v a l ,   b y t e O f f s e t ,   e n c o d i n g ,   d i r )   {   
     i f   ( t y p e o f   b y t e O f f s e t   = = =   ' s t r i n g ' )   {   
         e n c o d i n g   =   b y t e O f f s e t ;   
         b y t e O f f s e t   =   u n d e f i n e d ;   
     }   e l s e   i f   ( b y t e O f f s e t   >   0 x 7 f f f f f f f )   {   
         b y t e O f f s e t   =   0 x 7 f f f f f f f ;   
     }   e l s e   i f   ( b y t e O f f s e t   <   - 0 x 8 0 0 0 0 0 0 0 )   {   
         b y t e O f f s e t   =   - 0 x 8 0 0 0 0 0 0 0 ;   
     }   
     b y t e O f f s e t   =   + b y t e O f f s e t ;     / /   C o e r c e   t o   N u m b e r .   
     i f   ( i s N a N ( b y t e O f f s e t ) )   {   
         / /   I f   t h e   o f f s e t   i s   u n d e f i n e d ,   n u l l ,   N a N ,   " f o o " ,   e t c ,   s e a r c h   w h o l e   b u f f e r .   
         b y t e O f f s e t   =   d i r   ?   0   :   ( b u f f e r . l e n g t h   -   1 ) ;   
     }   
     d i r   =   ! ! d i r ;     / /   C a s t   t o   b o o l .   
   
     i f   ( t y p e o f   v a l   = = =   ' s t r i n g ' )   {   
         i f   ( e n c o d i n g   = = =   u n d e f i n e d )   {   
             r e t u r n   b i n d i n g . i n d e x O f S t r i n g ( b u f f e r ,   v a l ,   b y t e O f f s e t ,   e n c o d i n g ,   d i r ) ;   
         }   
         r e t u r n   s l o w I n d e x O f ( b u f f e r ,   v a l ,   b y t e O f f s e t ,   e n c o d i n g ,   d i r ) ;   
     }   e l s e   i f   ( v a l   i n s t a n c e o f   B u f f e r )   {   
         r e t u r n   b i n d i n g . i n d e x O f B u f f e r ( b u f f e r ,   v a l ,   b y t e O f f s e t ,   e n c o d i n g ,   d i r ) ;   
     }   e l s e   i f   ( t y p e o f   v a l   = = =   ' n u m b e r ' )   {   
         r e t u r n   b i n d i n g . i n d e x O f N u m b e r ( b u f f e r ,   v a l ,   b y t e O f f s e t ,   d i r ) ;   
     }   
   
     t h r o w   n e w   T y p e E r r o r ( ' " v a l "   a r g u m e n t   m u s t   b e   s t r i n g ,   n u m b e r   o r   B u f f e r ' ) ;   
 }   
   
   
 f u n c t i o n   s l o w I n d e x O f ( b u f f e r ,   v a l ,   b y t e O f f s e t ,   e n c o d i n g ,   d i r )   {   
     v a r   l o w e r e d C a s e   =   f a l s e ;   
     f o r   ( ; ; )   {   
         s w i t c h   ( e n c o d i n g )   {   
             c a s e   ' u t f 8 ' :   
             c a s e   ' u t f - 8 ' :   
             c a s e   ' u c s 2 ' :   
             c a s e   ' u c s - 2 ' :   
             c a s e   ' u t f 1 6 l e ' :   
             c a s e   ' u t f - 1 6 l e ' :   
             c a s e   ' l a t i n 1 ' :   
             c a s e   ' b i n a r y ' :   
                 r e t u r n   b i n d i n g . i n d e x O f S t r i n g ( b u f f e r ,   v a l ,   b y t e O f f s e t ,   e n c o d i n g ,   d i r ) ;   
   
             c a s e   ' b a s e 6 4 ' :   
             c a s e   ' a s c i i ' :   
             c a s e   ' h e x ' :   
                 r e t u r n   b i n d i n g . i n d e x O f B u f f e r (   
                         b u f f e r ,   B u f f e r . f r o m ( v a l ,   e n c o d i n g ) ,   b y t e O f f s e t ,   e n c o d i n g ,   d i r ) ;   
   
             d e f a u l t :   
                 i f   ( l o w e r e d C a s e )   {   
                     t h r o w   n e w   T y p e E r r o r ( ' U n k n o w n   e n c o d i n g :   '   +   e n c o d i n g ) ;   
                 }   
   
                 e n c o d i n g   =   ( ' '   +   e n c o d i n g ) . t o L o w e r C a s e ( ) ;   
                 l o w e r e d C a s e   =   t r u e ;   
         }   
     }   
 }   
   
   
 B u f f e r . p r o t o t y p e . i n d e x O f   =   f u n c t i o n   i n d e x O f ( v a l ,   b y t e O f f s e t ,   e n c o d i n g )   {   
     r e t u r n   b i d i r e c t i o n a l I n d e x O f ( t h i s ,   v a l ,   b y t e O f f s e t ,   e n c o d i n g ,   t r u e ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . l a s t I n d e x O f   =   f u n c t i o n   l a s t I n d e x O f ( v a l ,   b y t e O f f s e t ,   e n c o d i n g )   {   
     r e t u r n   b i d i r e c t i o n a l I n d e x O f ( t h i s ,   v a l ,   b y t e O f f s e t ,   e n c o d i n g ,   f a l s e ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . i n c l u d e s   =   f u n c t i o n   i n c l u d e s ( v a l ,   b y t e O f f s e t ,   e n c o d i n g )   {   
     r e t u r n   t h i s . i n d e x O f ( v a l ,   b y t e O f f s e t ,   e n c o d i n g )   ! = =   - 1 ;   
 } ;   
   
   
 / /   U s a g e :   
 / /         b u f f e r . f i l l ( n u m b e r [ ,   o f f s e t [ ,   e n d ] ] )   
 / /         b u f f e r . f i l l ( b u f f e r [ ,   o f f s e t [ ,   e n d ] ] )   
 / /         b u f f e r . f i l l ( s t r i n g [ ,   o f f s e t [ ,   e n d ] ] [ ,   e n c o d i n g ] )   
 B u f f e r . p r o t o t y p e . f i l l   =   f u n c t i o n   f i l l ( v a l ,   s t a r t ,   e n d ,   e n c o d i n g )   {   
     / /   H a n d l e   s t r i n g   c a s e s :   
     i f   ( t y p e o f   v a l   = = =   ' s t r i n g ' )   {   
         i f   ( t y p e o f   s t a r t   = = =   ' s t r i n g ' )   {   
             e n c o d i n g   =   s t a r t ;   
             s t a r t   =   0 ;   
             e n d   =   t h i s . l e n g t h ;   
         }   e l s e   i f   ( t y p e o f   e n d   = = =   ' s t r i n g ' )   {   
             e n c o d i n g   =   e n d ;   
             e n d   =   t h i s . l e n g t h ;   
         }   
         i f   ( v a l . l e n g t h   = = =   1 )   {   
             v a r   c o d e   =   v a l . c h a r C o d e A t ( 0 ) ;   
             i f   ( c o d e   <   2 5 6 )   
                 v a l   =   c o d e ;   
         }   
         i f   ( v a l . l e n g t h   = = =   0 )   {   
             / /   P r e v i o u s l y ,   i f   v a l   = = =   ' ' ,   t h e   B u f f e r   w o u l d   n o t   f i l l ,   
             / /   w h i c h   i s   r a t h e r   s u r p r i s i n g .   
             v a l   =   0 ;   
         }   
         i f   ( e n c o d i n g   ! = =   u n d e f i n e d   & &   t y p e o f   e n c o d i n g   ! = =   ' s t r i n g ' )   {   
             t h r o w   n e w   T y p e E r r o r ( ' e n c o d i n g   m u s t   b e   a   s t r i n g ' ) ;   
         }   
         i f   ( t y p e o f   e n c o d i n g   = = =   ' s t r i n g '   & &   ! B u f f e r . i s E n c o d i n g ( e n c o d i n g ) )   {   
             t h r o w   n e w   T y p e E r r o r ( ' U n k n o w n   e n c o d i n g :   '   +   e n c o d i n g ) ;   
         }   
   
     }   e l s e   i f   ( t y p e o f   v a l   = = =   ' n u m b e r ' )   {   
         v a l   =   v a l   &   2 5 5 ;   
     }   
   
     / /   I n v a l i d   r a n g e s   a r e   n o t   s e t   t o   a   d e f a u l t ,   s o   c a n   r a n g e   c h e c k   e a r l y .   
     i f   ( s t a r t   <   0   | |   e n d   >   t h i s . l e n g t h )   
         t h r o w   n e w   R a n g e E r r o r ( ' O u t   o f   r a n g e   i n d e x ' ) ;   
   
     i f   ( e n d   < =   s t a r t )   
         r e t u r n   t h i s ;   
   
     s t a r t   =   s t a r t   > > >   0 ;   
     e n d   =   e n d   = = =   u n d e f i n e d   ?   t h i s . l e n g t h   :   e n d   > > >   0 ;   
   
     b i n d i n g . f i l l ( t h i s ,   v a l ,   s t a r t ,   e n d ,   e n c o d i n g ) ;   
   
     r e t u r n   t h i s ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e   =   f u n c t i o n ( s t r i n g ,   o f f s e t ,   l e n g t h ,   e n c o d i n g )   {   
     / /   B u f f e r # w r i t e ( s t r i n g ) ;   
     i f   ( o f f s e t   = = =   u n d e f i n e d )   {   
         e n c o d i n g   =   ' u t f 8 ' ;   
         l e n g t h   =   t h i s . l e n g t h ;   
         o f f s e t   =   0 ;   
   
     / /   B u f f e r # w r i t e ( s t r i n g ,   e n c o d i n g )   
     }   e l s e   i f   ( l e n g t h   = = =   u n d e f i n e d   & &   t y p e o f   o f f s e t   = = =   ' s t r i n g ' )   {   
         e n c o d i n g   =   o f f s e t ;   
         l e n g t h   =   t h i s . l e n g t h ;   
         o f f s e t   =   0 ;   
   
     / /   B u f f e r # w r i t e ( s t r i n g ,   o f f s e t [ ,   l e n g t h ] [ ,   e n c o d i n g ] )   
     }   e l s e   i f   ( i s F i n i t e ( o f f s e t ) )   {   
         o f f s e t   =   o f f s e t   > > >   0 ;   
         i f   ( i s F i n i t e ( l e n g t h ) )   {   
             l e n g t h   =   l e n g t h   > > >   0 ;   
             i f   ( e n c o d i n g   = = =   u n d e f i n e d )   
                 e n c o d i n g   =   ' u t f 8 ' ;   
         }   e l s e   {   
             e n c o d i n g   =   l e n g t h ;   
             l e n g t h   =   u n d e f i n e d ;   
         }   
     }   e l s e   {   
         / /   i f   s o m e o n e   i s   s t i l l   c a l l i n g   t h e   o b s o l e t e   f o r m   o f   w r i t e ( ) ,   t e l l   t h e m .   
         / /   w e   d o n ' t   w a n t   e g   b u f . w r i t e ( " f o o " ,   " u t f 8 " ,   1 0 )   t o   s i l e n t l y   t u r n   i n t o   
         / /   b u f . w r i t e ( " f o o " ,   " u t f 8 " ) ,   s o   w e   c a n ' t   i g n o r e   e x t r a   a r g s   
         t h r o w   n e w   E r r o r ( ' B u f f e r . w r i t e ( s t r i n g ,   e n c o d i n g ,   o f f s e t [ ,   l e n g t h ] )   '   +   
                                         ' i s   n o   l o n g e r   s u p p o r t e d ' ) ;   
     }   
   
     v a r   r e m a i n i n g   =   t h i s . l e n g t h   -   o f f s e t ;   
     i f   ( l e n g t h   = = =   u n d e f i n e d   | |   l e n g t h   >   r e m a i n i n g )   
         l e n g t h   =   r e m a i n i n g ;   
   
     i f   ( s t r i n g . l e n g t h   >   0   & &   ( l e n g t h   <   0   | |   o f f s e t   <   0 ) )   
         t h r o w   n e w   R a n g e E r r o r ( ' A t t e m p t   t o   w r i t e   o u t s i d e   b u f f e r   b o u n d s ' ) ;   
   
     i f   ( ! e n c o d i n g )   
         e n c o d i n g   =   ' u t f 8 ' ;   
   
     v a r   l o w e r e d C a s e   =   f a l s e ;   
     f o r   ( ; ; )   {   
         s w i t c h   ( e n c o d i n g )   {   
             c a s e   ' h e x ' :   
                 r e t u r n   t h i s . h e x W r i t e ( s t r i n g ,   o f f s e t ,   l e n g t h ) ;   
   
             c a s e   ' u t f 8 ' :   
             c a s e   ' u t f - 8 ' :   
                 r e t u r n   t h i s . u t f 8 W r i t e ( s t r i n g ,   o f f s e t ,   l e n g t h ) ;   
   
             c a s e   ' a s c i i ' :   
                 r e t u r n   t h i s . a s c i i W r i t e ( s t r i n g ,   o f f s e t ,   l e n g t h ) ;   
   
             c a s e   ' l a t i n 1 ' :   
             c a s e   ' b i n a r y ' :   
                 r e t u r n   t h i s . l a t i n 1 W r i t e ( s t r i n g ,   o f f s e t ,   l e n g t h ) ;   
   
             c a s e   ' b a s e 6 4 ' :   
                 / /   W a r n i n g :   m a x L e n g t h   n o t   t a k e n   i n t o   a c c o u n t   i n   b a s e 6 4 W r i t e   
                 r e t u r n   t h i s . b a s e 6 4 W r i t e ( s t r i n g ,   o f f s e t ,   l e n g t h ) ;   
   
             c a s e   ' u c s 2 ' :   
             c a s e   ' u c s - 2 ' :   
             c a s e   ' u t f 1 6 l e ' :   
             c a s e   ' u t f - 1 6 l e ' :   
                 r e t u r n   t h i s . u c s 2 W r i t e ( s t r i n g ,   o f f s e t ,   l e n g t h ) ;   
   
             d e f a u l t :   
                 i f   ( l o w e r e d C a s e )   
                     t h r o w   n e w   T y p e E r r o r ( ' U n k n o w n   e n c o d i n g :   '   +   e n c o d i n g ) ;   
                 e n c o d i n g   =   ( ' '   +   e n c o d i n g ) . t o L o w e r C a s e ( ) ;   
                 l o w e r e d C a s e   =   t r u e ;   
         }   
     }   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . t o J S O N   =   f u n c t i o n ( )   {   
     r e t u r n   {   
         t y p e :   ' B u f f e r ' ,   
         d a t a :   A r r a y . p r o t o t y p e . s l i c e . c a l l ( t h i s ,   0 )   
     } ;   
 } ;   
   
   
 f u n c t i o n   a d j u s t O f f s e t ( o f f s e t ,   l e n g t h )   {   
     o f f s e t   =   + o f f s e t ;   
     i f   ( o f f s e t   = = =   0   | |   N u m b e r . i s N a N ( o f f s e t ) )   {   
         r e t u r n   0 ;   
     }   
     i f   ( o f f s e t   <   0 )   {   
         o f f s e t   + =   l e n g t h ;   
         r e t u r n   o f f s e t   >   0   ?   o f f s e t   :   0 ;   
     }   e l s e   {   
         r e t u r n   o f f s e t   <   l e n g t h   ?   o f f s e t   :   l e n g t h ;   
     }   
 }   
   
   
 B u f f e r . p r o t o t y p e . s l i c e   =   f u n c t i o n   s l i c e ( s t a r t ,   e n d )   {   
     c o n s t   s r c L e n g t h   =   t h i s . l e n g t h ;   
     s t a r t   =   a d j u s t O f f s e t ( s t a r t ,   s r c L e n g t h ) ;   
     e n d   =   e n d   ! = =   u n d e f i n e d   ?   a d j u s t O f f s e t ( e n d ,   s r c L e n g t h )   :   s r c L e n g t h ;   
     c o n s t   n e w L e n g t h   =   e n d   >   s t a r t   ?   e n d   -   s t a r t   :   0 ;   
     r e t u r n   n e w   F a s t B u f f e r ( t h i s . b u f f e r ,   t h i s . b y t e O f f s e t   +   s t a r t ,   n e w L e n g t h ) ;   
 } ;   
   
   
 f u n c t i o n   c h e c k O f f s e t ( o f f s e t ,   e x t ,   l e n g t h )   {   
     i f   ( o f f s e t   +   e x t   >   l e n g t h )   
         t h r o w   n e w   R a n g e E r r o r ( ' I n d e x   o u t   o f   r a n g e ' ) ;   
 }   
   
   
 B u f f e r . p r o t o t y p e . r e a d U I n t L E   =   f u n c t i o n ( o f f s e t ,   b y t e L e n g t h ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     b y t e L e n g t h   =   b y t e L e n g t h   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   b y t e L e n g t h ,   t h i s . l e n g t h ) ;   
   
     v a r   v a l   =   t h i s [ o f f s e t ] ;   
     v a r   m u l   =   1 ;   
     v a r   i   =   0 ;   
     w h i l e   ( + + i   <   b y t e L e n g t h   & &   ( m u l   * =   0 x 1 0 0 ) )   
         v a l   + =   t h i s [ o f f s e t   +   i ]   *   m u l ;   
   
     r e t u r n   v a l ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d U I n t B E   =   f u n c t i o n ( o f f s e t ,   b y t e L e n g t h ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     b y t e L e n g t h   =   b y t e L e n g t h   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   b y t e L e n g t h ,   t h i s . l e n g t h ) ;   
   
     v a r   v a l   =   t h i s [ o f f s e t   +   - - b y t e L e n g t h ] ;   
     v a r   m u l   =   1 ;   
     w h i l e   ( b y t e L e n g t h   >   0   & &   ( m u l   * =   0 x 1 0 0 ) )   
         v a l   + =   t h i s [ o f f s e t   +   - - b y t e L e n g t h ]   *   m u l ;   
   
     r e t u r n   v a l ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d U I n t 8   =   f u n c t i o n ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   1 ,   t h i s . l e n g t h ) ;   
     r e t u r n   t h i s [ o f f s e t ] ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d U I n t 1 6 L E   =   f u n c t i o n ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   2 ,   t h i s . l e n g t h ) ;   
     r e t u r n   t h i s [ o f f s e t ]   |   ( t h i s [ o f f s e t   +   1 ]   < <   8 ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d U I n t 1 6 B E   =   f u n c t i o n ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   2 ,   t h i s . l e n g t h ) ;   
     r e t u r n   ( t h i s [ o f f s e t ]   < <   8 )   |   t h i s [ o f f s e t   +   1 ] ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d U I n t 3 2 L E   =   f u n c t i o n ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   4 ,   t h i s . l e n g t h ) ;   
   
     r e t u r n   ( ( t h i s [ o f f s e t ] )   |   
             ( t h i s [ o f f s e t   +   1 ]   < <   8 )   |   
             ( t h i s [ o f f s e t   +   2 ]   < <   1 6 ) )   +   
             ( t h i s [ o f f s e t   +   3 ]   *   0 x 1 0 0 0 0 0 0 ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d U I n t 3 2 B E   =   f u n c t i o n ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   4 ,   t h i s . l e n g t h ) ;   
   
     r e t u r n   ( t h i s [ o f f s e t ]   *   0 x 1 0 0 0 0 0 0 )   +   
             ( ( t h i s [ o f f s e t   +   1 ]   < <   1 6 )   |   
             ( t h i s [ o f f s e t   +   2 ]   < <   8 )   |   
             t h i s [ o f f s e t   +   3 ] ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d I n t L E   =   f u n c t i o n ( o f f s e t ,   b y t e L e n g t h ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     b y t e L e n g t h   =   b y t e L e n g t h   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   b y t e L e n g t h ,   t h i s . l e n g t h ) ;   
   
     v a r   v a l   =   t h i s [ o f f s e t ] ;   
     v a r   m u l   =   1 ;   
     v a r   i   =   0 ;   
     w h i l e   ( + + i   <   b y t e L e n g t h   & &   ( m u l   * =   0 x 1 0 0 ) )   
         v a l   + =   t h i s [ o f f s e t   +   i ]   *   m u l ;   
     m u l   * =   0 x 8 0 ;   
   
     i f   ( v a l   > =   m u l )   
         v a l   - =   M a t h . p o w ( 2 ,   8   *   b y t e L e n g t h ) ;   
   
     r e t u r n   v a l ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d I n t B E   =   f u n c t i o n ( o f f s e t ,   b y t e L e n g t h ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     b y t e L e n g t h   =   b y t e L e n g t h   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   b y t e L e n g t h ,   t h i s . l e n g t h ) ;   
   
     v a r   i   =   b y t e L e n g t h ;   
     v a r   m u l   =   1 ;   
     v a r   v a l   =   t h i s [ o f f s e t   +   - - i ] ;   
     w h i l e   ( i   >   0   & &   ( m u l   * =   0 x 1 0 0 ) )   
         v a l   + =   t h i s [ o f f s e t   +   - - i ]   *   m u l ;   
     m u l   * =   0 x 8 0 ;   
   
     i f   ( v a l   > =   m u l )   
         v a l   - =   M a t h . p o w ( 2 ,   8   *   b y t e L e n g t h ) ;   
   
     r e t u r n   v a l ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d I n t 8   =   f u n c t i o n ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   1 ,   t h i s . l e n g t h ) ;   
     v a r   v a l   =   t h i s [ o f f s e t ] ;   
     r e t u r n   ! ( v a l   &   0 x 8 0 )   ?   v a l   :   ( 0 x f f   -   v a l   +   1 )   *   - 1 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d I n t 1 6 L E   =   f u n c t i o n ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   2 ,   t h i s . l e n g t h ) ;   
     v a r   v a l   =   t h i s [ o f f s e t ]   |   ( t h i s [ o f f s e t   +   1 ]   < <   8 ) ;   
     r e t u r n   ( v a l   &   0 x 8 0 0 0 )   ?   v a l   |   0 x F F F F 0 0 0 0   :   v a l ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d I n t 1 6 B E   =   f u n c t i o n ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   2 ,   t h i s . l e n g t h ) ;   
     v a r   v a l   =   t h i s [ o f f s e t   +   1 ]   |   ( t h i s [ o f f s e t ]   < <   8 ) ;   
     r e t u r n   ( v a l   &   0 x 8 0 0 0 )   ?   v a l   |   0 x F F F F 0 0 0 0   :   v a l ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d I n t 3 2 L E   =   f u n c t i o n ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   4 ,   t h i s . l e n g t h ) ;   
   
     r e t u r n   ( t h i s [ o f f s e t ] )   |   
             ( t h i s [ o f f s e t   +   1 ]   < <   8 )   |   
             ( t h i s [ o f f s e t   +   2 ]   < <   1 6 )   |   
             ( t h i s [ o f f s e t   +   3 ]   < <   2 4 ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d I n t 3 2 B E   =   f u n c t i o n ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   4 ,   t h i s . l e n g t h ) ;   
   
     r e t u r n   ( t h i s [ o f f s e t ]   < <   2 4 )   |   
             ( t h i s [ o f f s e t   +   1 ]   < <   1 6 )   |   
             ( t h i s [ o f f s e t   +   2 ]   < <   8 )   |   
             ( t h i s [ o f f s e t   +   3 ] ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d F l o a t L E   =   f u n c t i o n   r e a d F l o a t L E ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   4 ,   t h i s . l e n g t h ) ;   
     r e t u r n   b i n d i n g . r e a d F l o a t L E ( t h i s ,   o f f s e t ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d F l o a t B E   =   f u n c t i o n   r e a d F l o a t B E ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   4 ,   t h i s . l e n g t h ) ;   
     r e t u r n   b i n d i n g . r e a d F l o a t B E ( t h i s ,   o f f s e t ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d D o u b l e L E   =   f u n c t i o n   r e a d D o u b l e L E ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   8 ,   t h i s . l e n g t h ) ;   
     r e t u r n   b i n d i n g . r e a d D o u b l e L E ( t h i s ,   o f f s e t ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . r e a d D o u b l e B E   =   f u n c t i o n   r e a d D o u b l e B E ( o f f s e t ,   n o A s s e r t )   {   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k O f f s e t ( o f f s e t ,   8 ,   t h i s . l e n g t h ) ;   
     r e t u r n   b i n d i n g . r e a d D o u b l e B E ( t h i s ,   o f f s e t ) ;   
 } ;   
   
   
 f u n c t i o n   c h e c k I n t ( b u f f e r ,   v a l u e ,   o f f s e t ,   e x t ,   m a x ,   m i n )   {   
     i f   ( ! ( b u f f e r   i n s t a n c e o f   B u f f e r ) )   
         t h r o w   n e w   T y p e E r r o r ( ' " b u f f e r "   a r g u m e n t   m u s t   b e   a   B u f f e r   i n s t a n c e ' ) ;   
     i f   ( v a l u e   >   m a x   | |   v a l u e   <   m i n )   
         t h r o w   n e w   T y p e E r r o r ( ' " v a l u e "   a r g u m e n t   i s   o u t   o f   b o u n d s ' ) ;   
     i f   ( o f f s e t   +   e x t   >   b u f f e r . l e n g t h )   
         t h r o w   n e w   R a n g e E r r o r ( ' I n d e x   o u t   o f   r a n g e ' ) ;   
 }   
   
   
 B u f f e r . p r o t o t y p e . w r i t e U I n t L E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   b y t e L e n g t h ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     b y t e L e n g t h   =   b y t e L e n g t h   > > >   0 ;   
     i f   ( ! n o A s s e r t )   {   
         c o n s t   m a x B y t e s   =   M a t h . p o w ( 2 ,   8   *   b y t e L e n g t h )   -   1 ;   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   b y t e L e n g t h ,   m a x B y t e s ,   0 ) ;   
     }   
   
     v a r   m u l   =   1 ;   
     v a r   i   =   0 ;   
     t h i s [ o f f s e t ]   =   v a l u e ;   
     w h i l e   ( + + i   <   b y t e L e n g t h   & &   ( m u l   * =   0 x 1 0 0 ) )   
         t h i s [ o f f s e t   +   i ]   =   ( v a l u e   /   m u l )   > > >   0 ;   
   
     r e t u r n   o f f s e t   +   b y t e L e n g t h ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e U I n t B E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   b y t e L e n g t h ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     b y t e L e n g t h   =   b y t e L e n g t h   > > >   0 ;   
     i f   ( ! n o A s s e r t )   {   
         c o n s t   m a x B y t e s   =   M a t h . p o w ( 2 ,   8   *   b y t e L e n g t h )   -   1 ;   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   b y t e L e n g t h ,   m a x B y t e s ,   0 ) ;   
     }   
   
     v a r   i   =   b y t e L e n g t h   -   1 ;   
     v a r   m u l   =   1 ;   
     t h i s [ o f f s e t   +   i ]   =   v a l u e ;   
     w h i l e   ( - - i   > =   0   & &   ( m u l   * =   0 x 1 0 0 ) )   
         t h i s [ o f f s e t   +   i ]   =   ( v a l u e   /   m u l )   > > >   0 ;   
   
     r e t u r n   o f f s e t   +   b y t e L e n g t h ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e U I n t 8   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   1 ,   0 x f f ,   0 ) ;   
     t h i s [ o f f s e t ]   =   v a l u e ;   
     r e t u r n   o f f s e t   +   1 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e U I n t 1 6 L E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   2 ,   0 x f f f f ,   0 ) ;   
     t h i s [ o f f s e t ]   =   v a l u e ;   
     t h i s [ o f f s e t   +   1 ]   =   ( v a l u e   > > >   8 ) ;   
     r e t u r n   o f f s e t   +   2 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e U I n t 1 6 B E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   2 ,   0 x f f f f ,   0 ) ;   
     t h i s [ o f f s e t ]   =   ( v a l u e   > > >   8 ) ;   
     t h i s [ o f f s e t   +   1 ]   =   v a l u e ;   
     r e t u r n   o f f s e t   +   2 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e U I n t 3 2 L E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   4 ,   0 x f f f f f f f f ,   0 ) ;   
     t h i s [ o f f s e t   +   3 ]   =   ( v a l u e   > > >   2 4 ) ;   
     t h i s [ o f f s e t   +   2 ]   =   ( v a l u e   > > >   1 6 ) ;   
     t h i s [ o f f s e t   +   1 ]   =   ( v a l u e   > > >   8 ) ;   
     t h i s [ o f f s e t ]   =   v a l u e ;   
     r e t u r n   o f f s e t   +   4 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e U I n t 3 2 B E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   4 ,   0 x f f f f f f f f ,   0 ) ;   
     t h i s [ o f f s e t ]   =   ( v a l u e   > > >   2 4 ) ;   
     t h i s [ o f f s e t   +   1 ]   =   ( v a l u e   > > >   1 6 ) ;   
     t h i s [ o f f s e t   +   2 ]   =   ( v a l u e   > > >   8 ) ;   
     t h i s [ o f f s e t   +   3 ]   =   v a l u e ;   
     r e t u r n   o f f s e t   +   4 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e I n t L E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   b y t e L e n g t h ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   {   
         c h e c k I n t ( t h i s ,   
                           v a l u e ,   
                           o f f s e t ,   
                           b y t e L e n g t h ,   
                           M a t h . p o w ( 2 ,   8   *   b y t e L e n g t h   -   1 )   -   1 ,   
                           - M a t h . p o w ( 2 ,   8   *   b y t e L e n g t h   -   1 ) ) ;   
     }   
   
     v a r   i   =   0 ;   
     v a r   m u l   =   1 ;   
     v a r   s u b   =   0 ;   
     t h i s [ o f f s e t ]   =   v a l u e ;   
     w h i l e   ( + + i   <   b y t e L e n g t h   & &   ( m u l   * =   0 x 1 0 0 ) )   {   
         i f   ( v a l u e   <   0   & &   s u b   = = =   0   & &   t h i s [ o f f s e t   +   i   -   1 ]   ! = =   0 )   
             s u b   =   1 ;   
         t h i s [ o f f s e t   +   i ]   =   ( ( v a l u e   /   m u l )   > >   0 )   -   s u b ;   
     }   
   
     r e t u r n   o f f s e t   +   b y t e L e n g t h ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e I n t B E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   b y t e L e n g t h ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   {   
         c h e c k I n t ( t h i s ,   
                           v a l u e ,   
                           o f f s e t ,   
                           b y t e L e n g t h ,   
                           M a t h . p o w ( 2 ,   8   *   b y t e L e n g t h   -   1 )   -   1 ,   
                           - M a t h . p o w ( 2 ,   8   *   b y t e L e n g t h   -   1 ) ) ;   
     }   
   
     v a r   i   =   b y t e L e n g t h   -   1 ;   
     v a r   m u l   =   1 ;   
     v a r   s u b   =   0 ;   
     t h i s [ o f f s e t   +   i ]   =   v a l u e ;   
     w h i l e   ( - - i   > =   0   & &   ( m u l   * =   0 x 1 0 0 ) )   {   
         i f   ( v a l u e   <   0   & &   s u b   = = =   0   & &   t h i s [ o f f s e t   +   i   +   1 ]   ! = =   0 )   
             s u b   =   1 ;   
         t h i s [ o f f s e t   +   i ]   =   ( ( v a l u e   /   m u l )   > >   0 )   -   s u b ;   
     }   
   
     r e t u r n   o f f s e t   +   b y t e L e n g t h ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e I n t 8   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   1 ,   0 x 7 f ,   - 0 x 8 0 ) ;   
     t h i s [ o f f s e t ]   =   v a l u e ;   
     r e t u r n   o f f s e t   +   1 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e I n t 1 6 L E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   2 ,   0 x 7 f f f ,   - 0 x 8 0 0 0 ) ;   
     t h i s [ o f f s e t ]   =   v a l u e ;   
     t h i s [ o f f s e t   +   1 ]   =   ( v a l u e   > > >   8 ) ;   
     r e t u r n   o f f s e t   +   2 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e I n t 1 6 B E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   2 ,   0 x 7 f f f ,   - 0 x 8 0 0 0 ) ;   
     t h i s [ o f f s e t ]   =   ( v a l u e   > > >   8 ) ;   
     t h i s [ o f f s e t   +   1 ]   =   v a l u e ;   
     r e t u r n   o f f s e t   +   2 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e I n t 3 2 L E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   4 ,   0 x 7 f f f f f f f ,   - 0 x 8 0 0 0 0 0 0 0 ) ;   
     t h i s [ o f f s e t ]   =   v a l u e ;   
     t h i s [ o f f s e t   +   1 ]   =   ( v a l u e   > > >   8 ) ;   
     t h i s [ o f f s e t   +   2 ]   =   ( v a l u e   > > >   1 6 ) ;   
     t h i s [ o f f s e t   +   3 ]   =   ( v a l u e   > > >   2 4 ) ;   
     r e t u r n   o f f s e t   +   4 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e I n t 3 2 B E   =   f u n c t i o n ( v a l u e ,   o f f s e t ,   n o A s s e r t )   {   
     v a l u e   =   + v a l u e ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         c h e c k I n t ( t h i s ,   v a l u e ,   o f f s e t ,   4 ,   0 x 7 f f f f f f f ,   - 0 x 8 0 0 0 0 0 0 0 ) ;   
     t h i s [ o f f s e t ]   =   ( v a l u e   > > >   2 4 ) ;   
     t h i s [ o f f s e t   +   1 ]   =   ( v a l u e   > > >   1 6 ) ;   
     t h i s [ o f f s e t   +   2 ]   =   ( v a l u e   > > >   8 ) ;   
     t h i s [ o f f s e t   +   3 ]   =   v a l u e ;   
     r e t u r n   o f f s e t   +   4 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e F l o a t L E   =   f u n c t i o n   w r i t e F l o a t L E ( v a l ,   o f f s e t ,   n o A s s e r t )   {   
     v a l   =   + v a l ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         b i n d i n g . w r i t e F l o a t L E ( t h i s ,   v a l ,   o f f s e t ) ;   
     e l s e   
         b i n d i n g . w r i t e F l o a t L E ( t h i s ,   v a l ,   o f f s e t ,   t r u e ) ;   
     r e t u r n   o f f s e t   +   4 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e F l o a t B E   =   f u n c t i o n   w r i t e F l o a t B E ( v a l ,   o f f s e t ,   n o A s s e r t )   {   
     v a l   =   + v a l ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         b i n d i n g . w r i t e F l o a t B E ( t h i s ,   v a l ,   o f f s e t ) ;   
     e l s e   
         b i n d i n g . w r i t e F l o a t B E ( t h i s ,   v a l ,   o f f s e t ,   t r u e ) ;   
     r e t u r n   o f f s e t   +   4 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e D o u b l e L E   =   f u n c t i o n   w r i t e D o u b l e L E ( v a l ,   o f f s e t ,   n o A s s e r t )   {   
     v a l   =   + v a l ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         b i n d i n g . w r i t e D o u b l e L E ( t h i s ,   v a l ,   o f f s e t ) ;   
     e l s e   
         b i n d i n g . w r i t e D o u b l e L E ( t h i s ,   v a l ,   o f f s e t ,   t r u e ) ;   
     r e t u r n   o f f s e t   +   8 ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . w r i t e D o u b l e B E   =   f u n c t i o n   w r i t e D o u b l e B E ( v a l ,   o f f s e t ,   n o A s s e r t )   {   
     v a l   =   + v a l ;   
     o f f s e t   =   o f f s e t   > > >   0 ;   
     i f   ( ! n o A s s e r t )   
         b i n d i n g . w r i t e D o u b l e B E ( t h i s ,   v a l ,   o f f s e t ) ;   
     e l s e   
         b i n d i n g . w r i t e D o u b l e B E ( t h i s ,   v a l ,   o f f s e t ,   t r u e ) ;   
     r e t u r n   o f f s e t   +   8 ;   
 } ;   
   
 c o n s t   s w a p 1 6 n   =   b i n d i n g . s w a p 1 6 ;   
 c o n s t   s w a p 3 2 n   =   b i n d i n g . s w a p 3 2 ;   
 c o n s t   s w a p 6 4 n   =   b i n d i n g . s w a p 6 4 ;   
   
 f u n c t i o n   s w a p ( b ,   n ,   m )   {   
     c o n s t   i   =   b [ n ] ;   
     b [ n ]   =   b [ m ] ;   
     b [ m ]   =   i ;   
 }   
   
   
 B u f f e r . p r o t o t y p e . s w a p 1 6   =   f u n c t i o n   s w a p 1 6 ( )   {   
     / /   F o r   B u f f e r . l e n g t h   <   1 2 8 ,   i t ' s   g e n e r a l l y   f a s t e r   t o   
     / /   d o   t h e   s w a p   i n   j a v a s c r i p t .   F o r   l a r g e r   b u f f e r s ,   
     / /   d r o p p i n g   d o w n   t o   t h e   n a t i v e   c o d e   i s   f a s t e r .   
     c o n s t   l e n   =   t h i s . l e n g t h ;   
     i f   ( l e n   %   2   ! = =   0 )   
         t h r o w   n e w   R a n g e E r r o r ( ' B u f f e r   s i z e   m u s t   b e   a   m u l t i p l e   o f   1 6 - b i t s ' ) ;   
     i f   ( l e n   <   1 2 8 )   {   
         f o r   ( v a r   i   =   0 ;   i   <   l e n ;   i   + =   2 )   
             s w a p ( t h i s ,   i ,   i   +   1 ) ;   
         r e t u r n   t h i s ;   
     }   
     r e t u r n   s w a p 1 6 n ( t h i s ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . s w a p 3 2   =   f u n c t i o n   s w a p 3 2 ( )   {   
     / /   F o r   B u f f e r . l e n g t h   <   1 9 2 ,   i t ' s   g e n e r a l l y   f a s t e r   t o   
     / /   d o   t h e   s w a p   i n   j a v a s c r i p t .   F o r   l a r g e r   b u f f e r s ,   
     / /   d r o p p i n g   d o w n   t o   t h e   n a t i v e   c o d e   i s   f a s t e r .   
     c o n s t   l e n   =   t h i s . l e n g t h ;   
     i f   ( l e n   %   4   ! = =   0 )   
         t h r o w   n e w   R a n g e E r r o r ( ' B u f f e r   s i z e   m u s t   b e   a   m u l t i p l e   o f   3 2 - b i t s ' ) ;   
     i f   ( l e n   <   1 9 2 )   {   
         f o r   ( v a r   i   =   0 ;   i   <   l e n ;   i   + =   4 )   {   
             s w a p ( t h i s ,   i ,   i   +   3 ) ;   
             s w a p ( t h i s ,   i   +   1 ,   i   +   2 ) ;   
         }   
         r e t u r n   t h i s ;   
     }   
     r e t u r n   s w a p 3 2 n ( t h i s ) ;   
 } ;   
   
   
 B u f f e r . p r o t o t y p e . s w a p 6 4   =   f u n c t i o n   s w a p 6 4 ( )   {   
     / /   F o r   B u f f e r . l e n g t h   <   1 9 2 ,   i t ' s   g e n e r a l l y   f a s t e r   t o   
     / /   d o   t h e   s w a p   i n   j a v a s c r i p t .   F o r   l a r g e r   b u f f e r s ,   
     / /   d r o p p i n g   d o w n   t o   t h e   n a t i v e   c o d e   i s   f a s t e r .   
     c o n s t   l e n   =   t h i s . l e n g t h ;   
     i f   ( l e n   %   8   ! = =   0 )   
         t h r o w   n e w   R a n g e E r r o r ( ' B u f f e r   s i z e   m u s t   b e   a   m u l t i p l e   o f   6 4 - b i t s ' ) ;   
     i f   ( l e n   <   1 9 2 )   {   
         f o r   ( v a r   i   =   0 ;   i   <   l e n ;   i   + =   8 )   {   
             s w a p ( t h i s ,   i ,   i   +   7 ) ;   
             s w a p ( t h i s ,   i   +   1 ,   i   +   6 ) ;   
             s w a p ( t h i s ,   i   +   2 ,   i   +   5 ) ;   
             s w a p ( t h i s ,   i   +   3 ,   i   +   4 ) ;   
         }   
         r e t u r n   t h i s ;   
     }   
     r e t u r n   s w a p 6 4 n ( t h i s ) ;   
 } ;   
   
 B u f f e r . p r o t o t y p e . t o L o c a l e S t r i n g   =   B u f f e r . p r o t o t y p e . t o S t r i n g ;   
 
 } ) ;   �  X   ��
 N O D E _ M O D U L E S / C H I L D _ P R O C E S S . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / *   
 *   F a k e   i m p l e m e n t a t i o n   o f   n o d e j s   c h i l d _ p r o c e s s   
 *   T h r o w   o n   s p a w n   
 * /     
 m o d u l e . e x p o r t s . s p a w n   =   f u n c t i o n ( ) {   
     t h r o w   n e w   E r r o r ( ' N o t   i m p l e m e n t e d   i n   S y N o d e ' ) ;   
 } 
 } ) ; �)  L   ��
 N O D E _ M O D U L E S / C O N S O L E . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / /   C o p y r i g h t   J o y e n t ,   I n c .   a n d   o t h e r   N o d e   c o n t r i b u t o r s .   
 / /   M o d i f i e d   b y   U n i t y B a s e   c o r e   t e a m   t o   b e   c o m p a t i b l e   w i t h   S y N o d e   
   
 v a r   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
   
 / * *   
   *   C o n s o l e   &   l o g   o u t p u t   f u n c t i o n s   
   *   P u t   s o m e t h i n g   t o   l o g   w i t h   l o g   l e v e l s   d e p e n d i n g   o n   m e t h o d .   I n   c a s e   o f   G U I   s e r v e r   d o   e c h o   t o   G U I   l o g   ( i f   e n a b l e d ) .   
   *   I n   c a s e   o f   c o m m a n d   l i n e   -   e c h o   t o   ` s t d o u t ` .   
   *   
   *   D o   n o t   c r e a t e   t h i s   c l a s s   d i r e c t l y   -   u s e   g l o b a l   { @ l i n k   c o n s o l e }   a l r e a d y   c r e a t e d   b y   U B .   
   *   
   *             c o n s o l e . l o g ( ' % s   i s   a   % s   u s u a l l y   w i t h   w e i g h t   l e s s   t h e n   % d g r ' ,   ' a p p l e ' ,   ' f r u i t ' ,   1 0 0 ) ;   
   *             / / W i l l   o u t p u t   " a p p l e   i s   a   f r u i t   u s u a l l y   w i t h   w e i g h t   l e s s   t h e n   1 0 0 g r "   
   *             c o n s o l e . l o g ( ' a p p l e ' ,   ' f r u i t ' ,   1 0 0 ) ;   
   *             / / w i l l   o u t p u t   " a p p l e   f r u i t   1 0 0 "   
   *             c o n s o l e . d e b u g ( ' s o m e t h i n g ' ) ;   
   *             / /   w i l l   o u t p u t   t o   l o g   o n l y   i n   " D e b u g "   b u i l d   ( U B D . e x e )   
   *   
   *   A r g u m e n t s ,   p a s s e d   t o   c o n s o l e   o u t p u t   f u n c t i o n s   a r e   t r a n s f o r m e d   t o   s t r i n g   u s i n g   { @ l i n k   u t i l . f o r m a t }   c a l l .   
   *   
   *   @ m o d u l e   c o n s o l e   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 / * *   
   *   D o   n o t   c r e a t e   d i r e c t l y ,   u s e   { @ l i n k   c o n s o l e }   i n s t a n c e   f r o m   ` g l o b a l ` .   
   *   
   *             c o n s o l e . d e b u g ( ' Y e h ! ' ) ;   
   *   
   *   @ c l a s s   C o n s o l e   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
 f u n c t i o n   C o n s o l e ( s t d o u t ,   s t d e r r )   {   
     i f   ( ! ( t h i s   i n s t a n c e o f   C o n s o l e ) )   {   
         r e t u r n   n e w   C o n s o l e ( s t d o u t ,   s t d e r r ) ;   
     }   
     i f   ( ! s t d o u t   | |   t y p e o f   s t d o u t . w r i t e   ! = =   ' f u n c t i o n ' )   {   
         t h r o w   n e w   T y p e E r r o r ( ' C o n s o l e   e x p e c t s   a   w r i t a b l e   s t r e a m   i n s t a n c e ' ) ;   
     }   
     i f   ( ! s t d e r r )   {   
         s t d e r r   =   s t d o u t ;   
     }   
     v a r   p r o p   =   {   
         w r i t a b l e :   t r u e ,   
         e n u m e r a b l e :   f a l s e ,   
         c o n f i g u r a b l e :   t r u e   
     } ;   
     p r o p . v a l u e   =   s t d o u t ;   
     O b j e c t . d e f i n e P r o p e r t y ( t h i s ,   ' _ s t d o u t ' ,   p r o p ) ;   
     p r o p . v a l u e   =   s t d e r r ;   
     O b j e c t . d e f i n e P r o p e r t y ( t h i s ,   ' _ s t d e r r ' ,   p r o p ) ;   
     p r o p . v a l u e   =   { } ;   
     O b j e c t . d e f i n e P r o p e r t y ( t h i s ,   ' _ t i m e s ' ,   p r o p ) ;   
   
     / /   b i n d   t h e   p r o t o t y p e   f u n c t i o n s   t o   t h i s   C o n s o l e   i n s t a n c e   
     O b j e c t . k e y s ( C o n s o l e . p r o t o t y p e ) . f o r E a c h ( f u n c t i o n ( k )   {   
         t h i s [ k ]   =   t h i s [ k ] . b i n d ( t h i s ) ;   
     } ,   t h i s ) ;   
 }   
   
 / * *   
   *   O u t p u t   t o   l o g   w i t h   l o g   l e v e l   ` I n f o ` .   I n t e r n a l l y   u s e   u t i l . f o r m a t   f o r   c r e a t e   o u t p u t ,   s o   
   *   f o r m a t   c h a r s   c a n   b e   u s e d :   
   *   
   *     -   % s   -   S t r i n g .   
   *     -   % d   -   N u m b e r   ( b o t h   i n t e g e r   a n d   f l o a t ) .   
   *     -   % j   -   J S O N .   
   *     -   %   -   s i n g l e   p e r c e n t   s i g n   ( ' % ' ) .   T h i s   d o e s   n o t   c o n s u m e   a n   a r g u m e n t .   
   *   
   *             c o n s o l e . l o g ( ' % s   i s   a   % s   u s u a l l y   w i t h   w e i g h t   l e s s   t h e n   % d g r ' ,   ' a p p l e ' ,   ' f r u i t ' ,   1 0 0 ) ;   
   *             / / W i l l   o u t p u t   " a p p l e   i s   a   f r u i t   u s u a l l y   w i t h   w e i g h t   l e s s   t h e n   1 0 0 g r "   
   *   
   *             c o n s o l e . l o g ( ' a p p l e ' ,   ' f r u i t ' ,   1 0 0 ) ;   
   *             / / w i l l   o u t p u t   " a p p l e   f r u i t   1 0 0 "   
   *   
   *             c o n s o l e . l o g ( ' t h e   o b j e c t   J S O N   i s   % j ' ,   { a :   1 2 ,   b :   { i n n e r :   1 1 } } ) ;   
   *             / /   w i l l   o u t p u t   a   J S O N   o b j e c t   i n s t e a d   o f   [ o b j e c t   O b j e c t ]   
   *   
   *   @ p a r a m   { . . . * }   
   * /   
 C o n s o l e . p r o t o t y p e . l o g   =   f u n c t i o n ( )   {   
     t h i s . _ s t d o u t . w r i t e ( u t i l . f o r m a t . a p p l y ( t h i s ,   a r g u m e n t s )   +   ' \ n ' ) ;   
 } ;   
   
 / * *   
   *   O u t p u t   t o   l o g   w i t h   l o g   l e v e l   ` D e b u g ` .   I n   c a s e   { @ l i n k   p r o c e s s . i s D e b u g }   i s   f a l s e   -   d o   n o t h i n g   
   *   @ m e t h o d   
   *   @ p a r a m   { . . . * }   
   * /   
 C o n s o l e . p r o t o t y p e . d e b u g   =   p r o c e s s . i s D e b u g   ?   
 f u n c t i o n ( )   {   
         t h i s . _ s t d o u t . w r i t e ( u t i l . f o r m a t . a p p l y ( t h i s ,   a r g u m e n t s )   +   ' \ n ' ,   2 ) ;   / / U B   s p e c i f i c   
 }   :   
 f u n c t i o n ( )   {   
 } ;   
   
 / * *   
   *   O u t p u t   t o   l o g   w i t h   l o g   l e v e l   ` I n f o `   ( a l i a s   f o r   c o n s o l e . l o g )   
   *   @ m e t h o d   
   *   @ p a r a m   { . . . * }   
   * /   
 C o n s o l e . p r o t o t y p e . i n f o   =   C o n s o l e . p r o t o t y p e . l o g ;   
   
   
 / * *   
   *   O u t p u t   t o   l o g   w i t h   l o g   l e v e l   ` W a r n i n g ` .   I n   c a s e   o f   O S   c o n s o l e   e c h o   o u t p u t   t o   s t d e r r   
   *   @ p a r a m   { . . . * }   
   * /   
 C o n s o l e . p r o t o t y p e . w a r n   =   f u n c t i o n ( )   {   
     t h i s . _ s t d e r r . w r i t e ( u t i l . f o r m a t . a p p l y ( t h i s ,   a r g u m e n t s )   +   ' \ n ' ,   4 ) ;   / / U B   s p e c i f i c   
 } ;   
   
 / * *   
   *   O u t p u t   t o   l o g   w i t h   l o g   l e v e l   ` E r r o r ` .   I n   c a s e   o f   O S   c o n s o l e   e c h o   o u t p u t   t o   s t d e r r   
   *   @ p a r a m   { . . . * }   
   * /   
 C o n s o l e . p r o t o t y p e . e r r o r   =   f u n c t i o n ( )   {   
     t h i s . _ s t d e r r . w r i t e ( u t i l . f o r m a t . a p p l y ( t h i s ,   a r g u m e n t s )   +   ' \ n ' ,   5 ) ;   / / U B   s p e c i f i c   
 } ;   
   
 / * *   
   *   U s e s   u t i l . i n s p e c t   o n   o b j   a n d   p r i n t s   r e s u l t i n g   s t r i n g   t o   s t d o u t .   
   *   @ p a r a m   { O b j e c t }   o b j e c t   
   * /   
 C o n s o l e . p r o t o t y p e . d i r   =   f u n c t i o n ( o b j e c t )   {   
     t h i s . _ s t d o u t . w r i t e ( u t i l . i n s p e c t ( o b j e c t )   +   ' \ n ' ) ;   
 } ;   
   
 / * *   
   *   M a r k   a   t i m e .   
   *   @ p a r a m   { S t r i n g }   l a b e l   
   * /   
 C o n s o l e . p r o t o t y p e . t i m e   =   f u n c t i o n ( l a b e l )   {   
     t h i s . _ t i m e s [ l a b e l ]   =   D a t e . n o w ( ) ;   
 } ;   
   
 / * *   
   *   F i n i s h   t i m e r ,   r e c o r d   o u t p u t   
   *   @ e x a m p l e   
   *   
   *             c o n s o l e . t i m e ( ' 1 0 0 - e l e m e n t s ' ) ;   
   *                 f o r   ( v a r   i   =   0 ;   i   <   1 0 0 ;   i + + )   {   
   *                   ;   
   *             }   
   *             c o n s o l e . t i m e E n d ( ' 1 0 0 - e l e m e n t s ' ) ;   
   *   
   *   @ p a r a m   { s t r i n g }   l a b e l   
   * /   
 C o n s o l e . p r o t o t y p e . t i m e E n d   =   f u n c t i o n ( l a b e l )   {   
     v a r   t i m e   =   t h i s . _ t i m e s [ l a b e l ] ;   
     i f   ( ! t i m e )   {   
         t h r o w   n e w   E r r o r ( ' N o   s u c h   l a b e l :   '   +   l a b e l ) ;   
     }   
     v a r   d u r a t i o n   =   D a t e . n o w ( )   -   t i m e ;   
     t h i s . l o g ( ' % s :   % d m s ' ,   l a b e l ,   d u r a t i o n ) ;   
 } ;   
   
   
 C o n s o l e . p r o t o t y p e . t r a c e   =   f u n c t i o n ( )   {   
     / /   T O D O   p r o b a b l y   c a n   t o   d o   t h i s   b e t t e r   w i t h   V 8 ' s   d e b u g   o b j e c t   o n c e   t h a t   i s   
     / /   e x p o s e d .   
     v a r   e r r   =   n e w   E r r o r ;   
     e r r . n a m e   =   ' T r a c e ' ;   
     e r r . m e s s a g e   =   u t i l . f o r m a t . a p p l y ( t h i s ,   a r g u m e n t s ) ;   
     / / M P V   E r r o r . c a p t u r e S t a c k T r a c e ( e r r ,   a r g u m e n t s . c a l l e e ) ;   
     t h i s . e r r o r ( e r r . s t a c k ) ;   
 } ;   
   
 / * *   
   *   S i m i l a r   t o   { @ l i n k   a s s e r t # o k } ,   b u t   t h e   e r r o r   m e s s a g e   i s   f o r m a t t e d   a s   { @ l i n k   u t i l # f o r m a t   u t i l . f o r m a t ( m e s s a g e . . . ) } .   
   *   @ p a r a m   e x p r e s s i o n   
   * /   
 C o n s o l e . p r o t o t y p e . a s s e r t   =   f u n c t i o n ( e x p r e s s i o n )   {   
     i f   ( ! e x p r e s s i o n )   {   
         v a r   a r r   =   A r r a y . p r o t o t y p e . s l i c e . c a l l ( a r g u m e n t s ,   1 ) ;   
         r e q u i r e ( ' a s s e r t ' ) . o k ( f a l s e ,   u t i l . f o r m a t . a p p l y ( t h i s ,   a r r ) ) ;   
     }   
 } ;   
   
 m o d u l e . e x p o r t s   =   n e w   C o n s o l e ( p r o c e s s . s t d o u t ,   p r o c e s s . s t d e r r ) ;   
 m o d u l e . e x p o r t s . C o n s o l e   =   C o n s o l e ;   
 
 } ) ; �  L   ��
 N O D E _ M O D U L E S / C R Y P T O . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / / f a k e   m o d u l e   
   
 e x p o r t s . c r e a t e H a s h   =   e x p o r t s . H a s h   =   H a s h ;   
 f u n c t i o n   H a s h ( a l g o r i t h m ,   o p t i o n s )   {   
     i f   ( ! ( t h i s   i n s t a n c e o f   H a s h ) )   
         r e t u r n   n e w   H a s h ( a l g o r i t h m ,   o p t i o n s ) ;   
 / *     t h i s . _ b i n d i n g   =   n e w   b i n d i n g . H a s h ( a l g o r i t h m ) ;   
     L a z y T r a n s f o r m . c a l l ( t h i s ,   o p t i o n s ) ; * /   
     t h i s . f a k e   =   t r u e ;   
 }   
   
 e x p o r t s . r a n d o m B y t e s   =   r a n d o m B y t e s ;   
 f u n c t i o n   r a n d o m B y t e s ( s i z e ,   c a l l b a c k )   {   
 r e t u r n   ' z z z z z ' ;   
 }   
   
 
 } ) ;   �  D   ��
 N O D E _ M O D U L E S / D N S . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / /   F a k e     D N S   n o d e   m o d u l e   i n t e r f a c e   
 / /   F o r   c r e q u i r e ( ' d n s ' )   c o m p a r t i b i l i t y   o n l y   
 c o n s t   N O T _ I M P L E M E N T E D _ I N _ S Y N O D E   =   ' N o t   i m p l e m e n t e d   i n   S y N o d e '   
   
 f u n c t i o n   l o o k u p ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   l o o k u p S e r v i c e ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   g e t S e r v e r s ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   s e t S e r v e r s ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e 4 ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e 6 ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e C n a m e ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e M x ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e N s ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e T x t ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e S r v ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e P t r ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e N a p t r ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e s o l v e S o a ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
 f u n c t i o n   r e v e r s e ( )   {   
     t h r o w   n e w   E r r o r ( N O T _ I M P L E M E N T E D _ I N _ S Y N O D E )   
 }   
   
   
 m o d u l e . e x p o r t s   =   {   
     l o o k u p ,   
     l o o k u p S e r v i c e ,   
     g e t S e r v e r s ,   
     s e t S e r v e r s ,   
     r e s o l v e ,   
     r e s o l v e 4 ,   
     r e s o l v e 6 ,   
     r e s o l v e C n a m e ,   
     r e s o l v e M x ,   
     r e s o l v e N s ,   
     r e s o l v e T x t ,   
     r e s o l v e S r v ,   
     r e s o l v e P t r ,   
     r e s o l v e N a p t r ,   
     r e s o l v e S o a ,   
     r e v e r s e ,   
   
     / /   u v _ g e t a d d r i n f o   f l a g s   
     A D D R C O N F I G :   ' c a r e s . A I _ A D D R C O N F I G ' ,   
     V 4 M A P P E D :   ' c a r e s . A I _ V 4 M A P P E D ' ,   
   
     / /   E R R O R   C O D E S   
     N O D A T A :   ' E N O D A T A ' ,   
     F O R M E R R :   ' E F O R M E R R ' ,   
     S E R V F A I L :   ' E S E R V F A I L ' ,   
     N O T F O U N D :   ' E N O T F O U N D ' ,   
     N O T I M P :   ' E N O T I M P ' ,   
     R E F U S E D :   ' E R E F U S E D ' ,   
     B A D Q U E R Y :   ' E B A D Q U E R Y ' ,   
     B A D N A M E :   ' E B A D N A M E ' ,   
     B A D F A M I L Y :   ' E B A D F A M I L Y ' ,   
     B A D R E S P :   ' E B A D R E S P ' ,   
     C O N N R E F U S E D :   ' E C O N N R E F U S E D ' ,   
     T I M E O U T :   ' E T I M E O U T ' ,   
     E O F :   ' E O F ' ,   
     F I L E :   ' E F I L E ' ,   
     N O M E M :   ' E N O M E M ' ,   
     D E S T R U C T I O N :   ' E D E S T R U C T I O N ' ,   
     B A D S T R :   ' E B A D S T R ' ,   
     B A D F L A G S :   ' E B A D F L A G S ' ,   
     N O N A M E :   ' E N O N A M E ' ,   
     B A D H I N T S :   ' E B A D H I N T S ' ,   
     N O T I N I T I A L I Z E D :   ' E N O T I N I T I A L I Z E D ' ,   
     L O A D I P H L P A P I :   ' E L O A D I P H L P A P I ' ,   
     A D D R G E T N E T W O R K P A R A M S :   ' E A D D R G E T N E T W O R K P A R A M S ' ,   
     C A N C E L L E D :   ' E C A N C E L L E D '   
 } ;   
 
 } ) ; �v  L   ��
 N O D E _ M O D U L E S / E V E N T S . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ' u s e   s t r i c t ' ;   
 / * *   
   *   @ m o d u l e   e v e n t s   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 / * *   
   *   N o d e J S   l i k e   E v e n t E m i t t e r .   S e e   a l s o   < a   h r e f = " h t t p : / / n o d e j s . o r g / a p i / e v e n t s . h t m l " > N o d e J S   e v e n t s   d o c u m e n t a t i o n < / a >   
   *   
   *   T o   a d d   e v e n t   e m i t t i n g   a b i l i t y   t o   a n y   o b j e c t :   
   *   
   
           v a r   m y O b j e c t   =   { } ,   
           / / c o m p a t i b i l i t y   E v e n t E m i t t e r   =   r e q u i r e ( ' e v e n t s ' ) . E v e n t E m i t t e r ;   
           E v e n t E m i t t e r   =   r e q u i r e ( ' e v e n t s ' ) ;   
           / /   a d d   E v e n t E m i t t e r   t o   m y O b j e c t   
           E v e n t E m i t t e r . c a l l ( m y O b j e c t ) ;   
           v a r   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
           u t i l . _ e x t e n d ( m y O b j e c t ,   E v e n t E m i t t e r . p r o t o t y p e ) ;   
   
   *   I n   c a s e   o b j e c t   c r e a t e d   v i a   c o n s t r u c t o r   f u n c t i o n   
   
           f u n c t i o n   M y O b j e c t ( )   {   
                 E v e n t E m i t t e r . c a l l ( t h i s ) ;   
           }   
           u t i l . i n h e r i t s ( M y O b j e c t ,   E v e n t E m i t t e r ) ;   
   
           v a r   m y O b j e c t   =   n e w   M y O b j e c t ( ) ;   
   
   *   U s a g e :   
   
           m y O b j e c t . o n ( ' m y E v e n t ' ,   f u n c t i o n ( n u m ,   s t r ) { c o n s o l e . l o g ( n u m ,   s t r )   } ) ;   
   
           m y O b j e c t . e m i t ( ' m y E v e n t ' ,   1 ,   ' t w o ' ) ;   / /   o u t p u t :   1   t w o   
   
   *   
   *   @ c l a s s   E v e n t E m i t t e r   
   *   @ m i x i n   
   * /   
   
 f u n c t i o n   E v e n t E m i t t e r ( )   {   
     E v e n t E m i t t e r . i n i t . c a l l ( t h i s ) ;   
 }   
 m o d u l e . e x p o r t s   =   E v e n t E m i t t e r ;   
   
 / /   B a c k w a r d s - c o m p a t   w i t h   n o d e   0 . 1 0 . x   
 E v e n t E m i t t e r . E v e n t E m i t t e r   =   E v e n t E m i t t e r ;   
   
 / *   
   *   @ d e p r e c a t e d   T h i s   p r o p e r t y   n o t   u s e d   ( = = = f a l s e )   i n   U B .   A l s o   d e p r e c a t e d   i n   N o d e   
   * /   
 E v e n t E m i t t e r . u s i n g D o m a i n s   =   f a l s e ;   
   
 / / U B   E v e n t E m i t t e r . p r o t o t y p e . d o m a i n   =   u n d e f i n e d ;   
 / * *   
   *   P r i v a t e   c o l l e c t i o n   o f   e v e n t s .   
   *   @ p r i v a t e   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . _ e v e n t s   =   u n d e f i n e d ;   
 / * *   
   *   U s e   s e t / g e t   M a x L i s t e n e r s   i n s t e a d   d i r e c t   a c c e s s   
   *   @ p r i v a t e   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . _ m a x L i s t e n e r s   =   u n d e f i n e d ;   
   
 / /   B y   d e f a u l t   E v e n t E m i t t e r s   w i l l   p r i n t   a   w a r n i n g   i f   m o r e   t h a n   1 0   l i s t e n e r s   a r e   
 / /   a d d e d   t o   i t .   T h i s   i s   a   u s e f u l   d e f a u l t   w h i c h   h e l p s   f i n d i n g   m e m o r y   l e a k s .   
 E v e n t E m i t t e r . d e f a u l t M a x L i s t e n e r s   =   1 0 ;   
   
 / * *   
   *   @ p r i v a t e   
   * /   
 E v e n t E m i t t e r . i n i t   =   f u n c t i o n ( )   {   
     / / U B   t h i s . d o m a i n   =   n u l l ;   
     / / i f   ( E v e n t E m i t t e r . u s i n g D o m a i n s )   {   
     / /     / /   i f   t h e r e   i s   a n   a c t i v e   d o m a i n ,   t h e n   a t t a c h   t o   i t .   
     / /     d o m a i n   =   d o m a i n   | |   r e q u i r e ( ' d o m a i n ' ) ;   
     / /     i f   ( d o m a i n . a c t i v e   & &   ! ( t h i s   i n s t a n c e o f   d o m a i n . D o m a i n ) )   {   
     / /         t h i s . d o m a i n   =   d o m a i n . a c t i v e ;   
     / /     }   
     / / }   
   
     i f   ( ! t h i s . _ e v e n t s   | |   t h i s . _ e v e n t s   = = =   O b j e c t . g e t P r o t o t y p e O f ( t h i s ) . _ e v e n t s )   {   
         t h i s . _ e v e n t s   =   { } ;   
         t h i s . _ e v e n t s C o u n t   =   0 ;   
     }   
   
     t h i s . _ m a x L i s t e n e r s   =   t h i s . _ m a x L i s t e n e r s   | |   u n d e f i n e d ;   
 } ;   
   
 / * *   
   *   O b v i o u s l y   n o t   a l l   E m i t t e r s   s h o u l d   b e   l i m i t e d   t o   1 0 .   T h i s   f u n c t i o n   a l l o w s   
   *   t h a t   t o   b e   i n c r e a s e d .   S e t   t o   z e r o   f o r   u n l i m i t e d .   
   *   @ p a r a m   { N u m b e r }   n   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . s e t M a x L i s t e n e r s   =   f u n c t i o n   s e t M a x L i s t e n e r s ( n )   {   
     i f   ( t y p e o f   n   ! = =   ' n u m b e r '   | |   n   <   0   | |   i s N a N ( n ) )   
         t h r o w   n e w   T y p e E r r o r ( ' n   m u s t   b e   a   p o s i t i v e   n u m b e r ' ) ;   
     t h i s . _ m a x L i s t e n e r s   =   n ;   
     r e t u r n   t h i s ;   
 } ;   
   
 f u n c t i o n   $ g e t M a x L i s t e n e r s ( t h a t )   {   
     i f   ( t h a t . _ m a x L i s t e n e r s   = = =   u n d e f i n e d )   
         r e t u r n   E v e n t E m i t t e r . d e f a u l t M a x L i s t e n e r s ;   
     r e t u r n   t h a t . _ m a x L i s t e n e r s ;   
 }   
   
 / * *   
   *   
   *   @ r e t u r n   { N u m b e r }   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . g e t M a x L i s t e n e r s   =   f u n c t i o n   g e t M a x L i s t e n e r s ( )   {   
     r e t u r n   $ g e t M a x L i s t e n e r s ( t h i s ) ;   
 } ;   
   
 / /   T h e s e   s t a n d a l o n e   e m i t *   f u n c t i o n s   a r e   u s e d   t o   o p t i m i z e   c a l l i n g   o f   e v e n t   
 / /   h a n d l e r s   f o r   f a s t   c a s e s   b e c a u s e   e m i t ( )   i t s e l f   o f t e n   h a s   a   v a r i a b l e   n u m b e r   o f   
 / /   a r g u m e n t s   a n d   c a n   b e   d e o p t i m i z e d   b e c a u s e   o f   t h a t .   T h e s e   f u n c t i o n s   a l w a y s   h a v e   
 / /   t h e   s a m e   n u m b e r   o f   a r g u m e n t s   a n d   t h u s   d o   n o t   g e t   d e o p t i m i z e d ,   s o   t h e   c o d e   
 / /   i n s i d e   t h e m   c a n   e x e c u t e   f a s t e r .   
 f u n c t i o n   e m i t N o n e ( h a n d l e r ,   i s F n ,   s e l f )   {   
     i f   ( i s F n )   
         h a n d l e r . c a l l ( s e l f ) ;   
     e l s e   {   
         v a r   l e n   =   h a n d l e r . l e n g t h ;   
         v a r   l i s t e n e r s   =   a r r a y C l o n e ( h a n d l e r ,   l e n ) ;   
         f o r   ( v a r   i   =   0 ;   i   <   l e n ;   + + i )   
             l i s t e n e r s [ i ] . c a l l ( s e l f ) ;   
     }   
 }   
 f u n c t i o n   e m i t O n e ( h a n d l e r ,   i s F n ,   s e l f ,   a r g 1 )   {   
     i f   ( i s F n )   
         h a n d l e r . c a l l ( s e l f ,   a r g 1 ) ;   
     e l s e   {   
         v a r   l e n   =   h a n d l e r . l e n g t h ;   
         v a r   l i s t e n e r s   =   a r r a y C l o n e ( h a n d l e r ,   l e n ) ;   
         f o r   ( v a r   i   =   0 ;   i   <   l e n ;   + + i )   
             l i s t e n e r s [ i ] . c a l l ( s e l f ,   a r g 1 ) ;   
     }   
 }   
 f u n c t i o n   e m i t T w o ( h a n d l e r ,   i s F n ,   s e l f ,   a r g 1 ,   a r g 2 )   {   
     i f   ( i s F n )   
         h a n d l e r . c a l l ( s e l f ,   a r g 1 ,   a r g 2 ) ;   
     e l s e   {   
         v a r   l e n   =   h a n d l e r . l e n g t h ;   
         v a r   l i s t e n e r s   =   a r r a y C l o n e ( h a n d l e r ,   l e n ) ;   
         f o r   ( v a r   i   =   0 ;   i   <   l e n ;   + + i )   
             l i s t e n e r s [ i ] . c a l l ( s e l f ,   a r g 1 ,   a r g 2 ) ;   
     }   
 }   
 f u n c t i o n   e m i t T h r e e ( h a n d l e r ,   i s F n ,   s e l f ,   a r g 1 ,   a r g 2 ,   a r g 3 )   {   
     i f   ( i s F n )   
         h a n d l e r . c a l l ( s e l f ,   a r g 1 ,   a r g 2 ,   a r g 3 ) ;   
     e l s e   {   
         v a r   l e n   =   h a n d l e r . l e n g t h ;   
         v a r   l i s t e n e r s   =   a r r a y C l o n e ( h a n d l e r ,   l e n ) ;   
         f o r   ( v a r   i   =   0 ;   i   <   l e n ;   + + i )   
             l i s t e n e r s [ i ] . c a l l ( s e l f ,   a r g 1 ,   a r g 2 ,   a r g 3 ) ;   
     }   
 }   
   
 f u n c t i o n   e m i t M a n y ( h a n d l e r ,   i s F n ,   s e l f ,   a r g s )   {   
     i f   ( i s F n )   
         h a n d l e r . a p p l y ( s e l f ,   a r g s ) ;   
     e l s e   {   
         v a r   l e n   =   h a n d l e r . l e n g t h ;   
         v a r   l i s t e n e r s   =   a r r a y C l o n e ( h a n d l e r ,   l e n ) ;   
         f o r   ( v a r   i   =   0 ;   i   <   l e n ;   + + i )   
             l i s t e n e r s [ i ] . a p p l y ( s e l f ,   a r g s ) ;   
     }   
 }   
   
 / * *   
   *   E x e c u t e   e a c h   o f   t h e   l i s t e n e r s   i n   o r d e r   w i t h   t h e   s u p p l i e d   a r g u m e n t s .   
   *   R e t u r n s   t r u e   i f   e v e n t   h a d   l i s t e n e r s ,   f a l s e   o t h e r w i s e .   
   *   
   *   @ p a r a m   { S t r i n g }   t y p e   E v e n t   n a m e   
   *   @ p a r a m   { . . . * }   e v e n t A r g s   A r g u m e n t s ,   p a s s e d   t o   l i s t e n e r s   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . e m i t   =   f u n c t i o n   e m i t ( t y p e )   {   
     v a r   e r ,   h a n d l e r ,   l e n ,   a r g s ,   i ,   e v e n t s / * U B   d o m a i n * / ;   
     / / U B   v a r   n e e d D o m a i n E x i t   =   f a l s e ;   
     v a r   d o E r r o r   =   ( t y p e   = = =   ' e r r o r ' ) ;   
   
     e v e n t s   =   t h i s . _ e v e n t s ;   
     i f   ( e v e n t s )   
         d o E r r o r   =   ( d o E r r o r   & &   e v e n t s . e r r o r   = =   n u l l ) ;   
     e l s e   i f   ( ! d o E r r o r )   
         r e t u r n   f a l s e ;   
   
         / / U B   d o m a i n   =   t h i s . d o m a i n ;   
   
     / /   I f   t h e r e   i s   n o   ' e r r o r '   e v e n t   l i s t e n e r   t h e n   t h r o w .   
     i f   ( d o E r r o r )   {   
         e r   =   a r g u m e n t s [ 1 ] ;   
         / / U B   
         / / i f   ( d o m a i n )   {   
         / /     i f   ( ! e r )   
         / /         e r   =   n e w   E r r o r ( ' U n c a u g h t ,   u n s p e c i f i e d   " e r r o r "   e v e n t . ' ) ;   
         / /     e r . d o m a i n E m i t t e r   =   t h i s ;   
         / /     e r . d o m a i n   =   d o m a i n ;   
         / /     e r . d o m a i n T h r o w n   =   f a l s e ;   
         / /     d o m a i n . e m i t ( ' e r r o r ' ,   e r ) ;   
         / / }   e l s e   
         i f   ( e r   i n s t a n c e o f   E r r o r )   {   
             t h r o w   e r ;   / /   U n h a n d l e d   ' e r r o r '   e v e n t   
         }   e l s e   {   
             / /   A t   l e a s t   g i v e   s o m e   k i n d   o f   c o n t e x t   t o   t h e   u s e r   
             v a r   e r r   =   n e w   E r r o r ( ' U n c a u g h t ,   u n s p e c i f i e d   " e r r o r "   e v e n t .   ( '   +   e r   +   ' ) ' ) ;   
             e r r . c o n t e x t   =   e r ;   
             t h r o w   e r r ;   
         }   
         r e t u r n   f a l s e ;   
     }   
   
     h a n d l e r   =   e v e n t s [ t y p e ] ;   
   
     i f   ( ! h a n d l e r )   
         r e t u r n   f a l s e ;   
   
     / / U B   
     / / i f   ( d o m a i n   & &   t h i s   ! = =   p r o c e s s )   {   
     / /     d o m a i n . e n t e r ( ) ;   
     / /     n e e d D o m a i n E x i t   =   t r u e ;   
     / / }   
   
     v a r   i s F n   =   t y p e o f   h a n d l e r   = = =   ' f u n c t i o n ' ;   
     l e n   =   a r g u m e n t s . l e n g t h ;   
     s w i t c h   ( l e n )   {   
         / /   f a s t   c a s e s   
         c a s e   1 :   
             e m i t N o n e ( h a n d l e r ,   i s F n ,   t h i s ) ;   
             b r e a k ;   
         c a s e   2 :   
             e m i t O n e ( h a n d l e r ,   i s F n ,   t h i s ,   a r g u m e n t s [ 1 ] ) ;   
             b r e a k ;   
         c a s e   3 :   
             e m i t T w o ( h a n d l e r ,   i s F n ,   t h i s ,   a r g u m e n t s [ 1 ] ,   a r g u m e n t s [ 2 ] ) ;   
             b r e a k ;   
         c a s e   4 :   
             e m i t T h r e e ( h a n d l e r ,   i s F n ,   t h i s ,   a r g u m e n t s [ 1 ] ,   a r g u m e n t s [ 2 ] ,   a r g u m e n t s [ 3 ] ) ;   
             b r e a k ;   
         / /   s l o w e r   
         d e f a u l t :   
             a r g s   =   n e w   A r r a y ( l e n   -   1 ) ;   
             f o r   ( i   =   1 ;   i   <   l e n ;   i + + )   
                 a r g s [ i   -   1 ]   =   a r g u m e n t s [ i ] ;   
             e m i t M a n y ( h a n d l e r ,   i s F n ,   t h i s ,   a r g s ) ;   
     }   
   
     / / U B   i f   ( n e e d D o m a i n E x i t )   
     / /     d o m a i n . e x i t ( ) ;   
   
     r e t u r n   t r u e ;   
 } ;   
   
 / * *   
   *   A d d s   a   l i s t e n e r   t o   t h e   e n d   o f   t h e   l i s t e n e r s   a r r a y   f o r   t h e   s p e c i f i e d   e v e n t .   
   *   W i l l   e m i t   ` n e w L i s t e n e r `   e v e n t   o n   s u c c e s s .   
   *   
   *   U s a g e   s a m p l e :   
   *   
   *             S e s s i o n . o n ( ' l o g i n ' ,   f u n c t i o n   ( )   {   
   *                     c o n s o l e . l o g ( ' s o m e o n e   c o n n e c t e d ! ' ) ;   
   *             } ) ;   
   *   
   *   R e t u r n s   e m i t t e r ,   s o   c a l l s   c a n   b e   c h a i n e d .   
   *   
   *   @ p a r a m   { S t r i n g }   t y p e   E v e n t   n a m e   
   *   @ p a r a m   { F u n c t i o n }   l i s t e n e r   
   *   @ r e t u r n   { E v e n t E m i t t e r }   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . a d d L i s t e n e r   =   f u n c t i o n   a d d L i s t e n e r ( t y p e ,   l i s t e n e r )   {   
     v a r   m ;   
     v a r   e v e n t s ;   
     v a r   e x i s t i n g ;   
   
     i f   ( t y p e o f   l i s t e n e r   ! = =   ' f u n c t i o n ' )   
         t h r o w   n e w   T y p e E r r o r ( ' l i s t e n e r   m u s t   b e   a   f u n c t i o n ' ) ;   
   
     e v e n t s   =   t h i s . _ e v e n t s ;   
     i f   ( ! e v e n t s )   {   
         e v e n t s   =   t h i s . _ e v e n t s   =   { } ;   
         t h i s . _ e v e n t s C o u n t   =   0 ;   
     }   e l s e   {   
         / /   T o   a v o i d   r e c u r s i o n   i n   t h e   c a s e   t h a t   t y p e   = = =   " n e w L i s t e n e r " !   B e f o r e   
         / /   a d d i n g   i t   t o   t h e   l i s t e n e r s ,   f i r s t   e m i t   " n e w L i s t e n e r " .   
         i f   ( e v e n t s . n e w L i s t e n e r )   {   
             / * *   @ f i r e s     n e w L i s t e n e r   * /   
             t h i s . e m i t ( ' n e w L i s t e n e r ' ,   t y p e ,   
                                 l i s t e n e r . l i s t e n e r   ?   l i s t e n e r . l i s t e n e r   :   l i s t e n e r ) ;   
   
             / /   R e - a s s i g n   ` e v e n t s `   b e c a u s e   a   n e w L i s t e n e r   h a n d l e r   c o u l d   h a v e   c a u s e d   t h e   
             / /   t h i s . _ e v e n t s   t o   b e   a s s i g n e d   t o   a   n e w   o b j e c t   
             e v e n t s   =   t h i s . _ e v e n t s ;   
         }   
         e x i s t i n g   =   e v e n t s [ t y p e ] ;   
     }   
   
     i f   ( ! e x i s t i n g )   {   
         / /   O p t i m i z e   t h e   c a s e   o f   o n e   l i s t e n e r .   D o n ' t   n e e d   t h e   e x t r a   a r r a y   o b j e c t .   
         e x i s t i n g   =   e v e n t s [ t y p e ]   =   l i s t e n e r ;   
         + + t h i s . _ e v e n t s C o u n t ;   
     }   e l s e   {   
         i f   ( t y p e o f   e x i s t i n g   = = =   ' f u n c t i o n ' )   {   
             / /   A d d i n g   t h e   s e c o n d   e l e m e n t ,   n e e d   t o   c h a n g e   t o   a r r a y .   
             e x i s t i n g   =   e v e n t s [ t y p e ]   =   [ e x i s t i n g ,   l i s t e n e r ] ;   
         }   e l s e   {   
             / /   I f   w e ' v e   a l r e a d y   g o t   a n   a r r a y ,   j u s t   a p p e n d .   
             e x i s t i n g . p u s h ( l i s t e n e r ) ;   
         }   
   
         / /   C h e c k   f o r   l i s t e n e r   l e a k   
         i f   ( ! e x i s t i n g . w a r n e d )   {   
             m   =   $ g e t M a x L i s t e n e r s ( t h i s ) ;   
             i f   ( m   & &   m   >   0   & &   e x i s t i n g . l e n g t h   >   m )   {   
                 e x i s t i n g . w a r n e d   =   t r u e ;   
                 c o n s o l e . e r r o r ( ' ( n o d e )   w a r n i n g :   p o s s i b l e   E v e n t E m i t t e r   m e m o r y   '   +   
                                             ' l e a k   d e t e c t e d .   % d   % s   l i s t e n e r s   a d d e d .   '   +   
                                             ' U s e   e m i t t e r . s e t M a x L i s t e n e r s ( )   t o   i n c r e a s e   l i m i t . ' ,   
                                             e x i s t i n g . l e n g t h ,   t y p e ) ;   
                 c o n s o l e . t r a c e ( ) ;   
             }   
         }   
     }   
   
     r e t u r n   t h i s ;   
 } ;   
   
 / * *   
   *   A l i a s   f o r   { @ l i n k   E v e n t E m i t t e r # a d d L i s t e n e r   a d d L i s t e n e r }   
   *   @ m e t h o d   
   *   @ p a r a m   { S t r i n g }   t y p e   E v e n t   n a m e   
   *   @ p a r a m   { F u n c t i o n }   l i s t e n e r   
   *   @ r e t u r n   { E v e n t E m i t t e r }   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . o n   =   E v e n t E m i t t e r . p r o t o t y p e . a d d L i s t e n e r ;   
   
 / * *   
   *   A d d s   a   o n e   t i m e   l i s t e n e r   f o r   t h e   e v e n t .   T h i s   l i s t e n e r   i s   i n v o k e d   o n l y   t h e   n e x t   t i m e   t h e   e v e n t   i s   f i r e d ,   a f t e r   w h i c h   i t   i s   r e m o v e d .   
   *   @ p a r a m   { S t r i n g }   t y p e   E v e n t   n a m e   
   *   @ p a r a m   { F u n c t i o n }   l i s t e n e r   
   *   @ r e t u r n   { E v e n t E m i t t e r }   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . o n c e   =   f u n c t i o n   o n c e ( t y p e ,   l i s t e n e r )   {   
     i f   ( t y p e o f   l i s t e n e r   ! = =   ' f u n c t i o n ' )   
         t h r o w   n e w   T y p e E r r o r ( ' l i s t e n e r   m u s t   b e   a   f u n c t i o n ' ) ;   
   
     v a r   f i r e d   =   f a l s e ;   
   
     f u n c t i o n   g ( )   {   
         t h i s . r e m o v e L i s t e n e r ( t y p e ,   g ) ;   
   
         i f   ( ! f i r e d )   {   
             f i r e d   =   t r u e ;   
             l i s t e n e r . a p p l y ( t h i s ,   a r g u m e n t s ) ;   
         }   
     }   
   
     g . l i s t e n e r   =   l i s t e n e r ;   
     t h i s . o n ( t y p e ,   g ) ;   
   
     r e t u r n   t h i s ;   
 } ;   
   
   
 / * *   
   *   R e m o v e   a   l i s t e n e r   f r o m   t h e   l i s t e n e r   a r r a y   f o r   t h e   s p e c i f i e d   e v e n t .   
   *   C a u t i o n :   c h a n g e s   a r r a y   i n d i c e s   i n   t h e   l i s t e n e r   a r r a y   b e h i n d   t h e   l i s t e n e r .   
   *   E m i t s   a   ' r e m o v e L i s t e n e r '   e v e n t   i f   t h e   l i s t e n e r   w a s   r e m o v e d .   
   *   
   *   @ p a r a m   { S t r i n g }   t y p e   E v e n t   n a m e   
   *   @ p a r a m   { F u n c t i o n }   l i s t e n e r   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . r e m o v e L i s t e n e r   =   
         f u n c t i o n   r e m o v e L i s t e n e r ( t y p e ,   l i s t e n e r )   {   
             v a r   l i s t ,   e v e n t s ,   p o s i t i o n ,   i ;   
   
             i f   ( t y p e o f   l i s t e n e r   ! = =   ' f u n c t i o n ' )   
                 t h r o w   n e w   T y p e E r r o r ( ' l i s t e n e r   m u s t   b e   a   f u n c t i o n ' ) ;   
   
             e v e n t s   =   t h i s . _ e v e n t s ;   
             i f   ( ! e v e n t s )   
                 r e t u r n   t h i s ;   
   
             l i s t   =   e v e n t s [ t y p e ] ;   
             i f   ( ! l i s t )   
                 r e t u r n   t h i s ;   
   
             i f   ( l i s t   = = =   l i s t e n e r   | |   ( l i s t . l i s t e n e r   & &   l i s t . l i s t e n e r   = = =   l i s t e n e r ) )   {   
                 i f   ( - - t h i s . _ e v e n t s C o u n t   = = =   0 )   
                     t h i s . _ e v e n t s   =   { } ;   
                 e l s e   {   
                     d e l e t e   e v e n t s [ t y p e ] ;   
                     i f   ( e v e n t s . r e m o v e L i s t e n e r )   
                         / * *   @ f i r e s   r e m o v e L i s t e n e r   * /   
                         t h i s . e m i t ( ' r e m o v e L i s t e n e r ' ,   t y p e ,   l i s t e n e r ) ;   
                 }   
             }   e l s e   i f   ( t y p e o f   l i s t   ! = =   ' f u n c t i o n ' )   {   
                 p o s i t i o n   =   - 1 ;   
   
                 f o r   ( i   =   l i s t . l e n g t h ;   i - -   >   0 ; )   {   
                     i f   ( l i s t [ i ]   = = =   l i s t e n e r   | |   
                             ( l i s t [ i ] . l i s t e n e r   & &   l i s t [ i ] . l i s t e n e r   = = =   l i s t e n e r ) )   {   
                         p o s i t i o n   =   i ;   
                         b r e a k ;   
                     }   
                 }   
   
                 i f   ( p o s i t i o n   <   0 )   
                     r e t u r n   t h i s ;   
   
                 i f   ( l i s t . l e n g t h   = = =   1 )   {   
                     l i s t [ 0 ]   =   u n d e f i n e d ;   
                     i f   ( - - t h i s . _ e v e n t s C o u n t   = = =   0 )   {   
                         t h i s . _ e v e n t s   =   { } ;   
                         r e t u r n   t h i s ;   
                     }   e l s e   {   
                         d e l e t e   e v e n t s [ t y p e ] ;   
                     }   
                 }   e l s e   {   
                     s p l i c e O n e ( l i s t ,   p o s i t i o n ) ;   
                 }   
   
                 i f   ( e v e n t s . r e m o v e L i s t e n e r )   
                     t h i s . e m i t ( ' r e m o v e L i s t e n e r ' ,   t y p e ,   l i s t e n e r ) ;   
             }   
   
             r e t u r n   t h i s ;   
         } ;   
   
 / * *   
   *   R e m o v e s   a l l   l i s t e n e r s ,   o r   t h o s e   o f   t h e   s p e c i f i e d   e v e n t .   
   *   I t ' s   n o t   a   g o o d   i d e a   t o   r e m o v e   l i s t e n e r s   t h a t   w e r e   a d d e d   e l s e w h e r e   i n   t h e   c o d e ,   
   *   e s p e c i a l l y   w h e n   i t ' s   o n   a n   e m i t t e r   t h a t   y o u   d i d n ' t   c r e a t e   ( e . g .   s o c k e t s   o r   f i l e   s t r e a m s ) .   
   *   
   *   R e t u r n s   e m i t t e r ,   s o   c a l l s   c a n   b e   c h a i n e d .   
   *   @ p a r a m   { S t r i n g }   t y p e   E v e n t   n a m e   
   *   @ r e t u r n   { E v e n t E m i t t e r }   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . r e m o v e A l l L i s t e n e r s   =   
         f u n c t i o n   r e m o v e A l l L i s t e n e r s ( t y p e )   {   
             v a r   l i s t e n e r s ,   e v e n t s ;   
   
             e v e n t s   =   t h i s . _ e v e n t s ;   
             i f   ( ! e v e n t s )   
                 r e t u r n   t h i s ;   
   
             / /   n o t   l i s t e n i n g   f o r   r e m o v e L i s t e n e r ,   n o   n e e d   t o   e m i t   
             i f   ( ! e v e n t s . r e m o v e L i s t e n e r )   {   
                 i f   ( a r g u m e n t s . l e n g t h   = = =   0 )   {   
                     t h i s . _ e v e n t s   =   { } ;   
                     t h i s . _ e v e n t s C o u n t   =   0 ;   
                 }   e l s e   i f   ( e v e n t s [ t y p e ] )   {   
                     i f   ( - - t h i s . _ e v e n t s C o u n t   = = =   0 )   
                         t h i s . _ e v e n t s   =   { } ;   
                     e l s e   
                         d e l e t e   e v e n t s [ t y p e ] ;   
                 }   
                 r e t u r n   t h i s ;   
             }   
   
             / /   e m i t   r e m o v e L i s t e n e r   f o r   a l l   l i s t e n e r s   o n   a l l   e v e n t s   
             i f   ( a r g u m e n t s . l e n g t h   = = =   0 )   {   
                 v a r   k e y s   =   O b j e c t . k e y s ( e v e n t s ) ;   
                 f o r   ( v a r   i   =   0 ,   k e y ;   i   <   k e y s . l e n g t h ;   + + i )   {   
                     k e y   =   k e y s [ i ] ;   
                     i f   ( k e y   = = =   ' r e m o v e L i s t e n e r ' )   c o n t i n u e ;   
                     t h i s . r e m o v e A l l L i s t e n e r s ( k e y ) ;   
                 }   
                 t h i s . r e m o v e A l l L i s t e n e r s ( ' r e m o v e L i s t e n e r ' ) ;   
                 t h i s . _ e v e n t s   =   { } ;   
                 t h i s . _ e v e n t s C o u n t   =   0 ;   
                 r e t u r n   t h i s ;   
             }   
   
             l i s t e n e r s   =   e v e n t s [ t y p e ] ;   
   
             i f   ( t y p e o f   l i s t e n e r s   = = =   ' f u n c t i o n ' )   {   
                 t h i s . r e m o v e L i s t e n e r ( t y p e ,   l i s t e n e r s ) ;   
             }   e l s e   i f   ( l i s t e n e r s )   {   
                 / /   L I F O   o r d e r   
                 d o   {   
                     t h i s . r e m o v e L i s t e n e r ( t y p e ,   l i s t e n e r s [ l i s t e n e r s . l e n g t h   -   1 ] ) ;   
                 }   w h i l e   ( l i s t e n e r s [ 0 ] ) ;   
             }   
   
             r e t u r n   t h i s ;   
         } ;   
   
 / * *   
   *   R e t u r n s   a n   a r r a y   o f   l i s t e n e r s   f o r   t h e   s p e c i f i e d   e v e n t .   
   *   @ p a r a m   { S t r i n g }   t y p e   E v e n t   n a m e   
   *   @ r e t u r n   { A r r a y . < F u n c t i o n > }   
   * /   
 E v e n t E m i t t e r . p r o t o t y p e . l i s t e n e r s   =   f u n c t i o n   l i s t e n e r s ( t y p e )   {   
     v a r   e v l i s t e n e r ;   
     v a r   r e t ;   
     v a r   e v e n t s   =   t h i s . _ e v e n t s ;   
   
     i f   ( ! e v e n t s )   
         r e t   =   [ ] ;   
     e l s e   {   
         e v l i s t e n e r   =   e v e n t s [ t y p e ] ;   
         i f   ( ! e v l i s t e n e r )   
             r e t   =   [ ] ;   
         e l s e   i f   ( t y p e o f   e v l i s t e n e r   = = =   ' f u n c t i o n ' )   
             r e t   =   [ e v l i s t e n e r ] ;   
         e l s e   
             r e t   =   a r r a y C l o n e ( e v l i s t e n e r ,   e v l i s t e n e r . l e n g t h ) ;   
     }   
   
     r e t u r n   r e t ;   
 } ;   
   
 / * *   
   *   R e t u r n   t h e   n u m b e r   o f   l i s t e n e r s   f o r   a   g i v e n   e v e n t .   
   *   @ p a r a m   { E v e n t E m i t t e r }   e m i t t e r   
   *   @ p a r a m   { S t r i n g }   t y p e   
   *   @ r e t u r n   { N u m b e r }   
   * /   
 E v e n t E m i t t e r . l i s t e n e r C o u n t   =   f u n c t i o n ( e m i t t e r ,   t y p e )   {   
     i f   ( t y p e o f   e m i t t e r . l i s t e n e r C o u n t   = = =   ' f u n c t i o n ' )   {   
         r e t u r n   e m i t t e r . l i s t e n e r C o u n t ( t y p e ) ;   
     }   e l s e   {   
         r e t u r n   l i s t e n e r C o u n t . c a l l ( e m i t t e r ,   t y p e ) ;   
     }   
 } ;   
   
 E v e n t E m i t t e r . p r o t o t y p e . l i s t e n e r C o u n t   =   l i s t e n e r C o u n t ;   
 f u n c t i o n   l i s t e n e r C o u n t ( t y p e )   {   
     c o n s t   e v e n t s   =   t h i s . _ e v e n t s ;   
   
     i f   ( e v e n t s )   {   
         c o n s t   e v l i s t e n e r   =   e v e n t s [ t y p e ] ;   
   
         i f   ( t y p e o f   e v l i s t e n e r   = = =   ' f u n c t i o n ' )   {   
             r e t u r n   1 ;   
         }   e l s e   i f   ( e v l i s t e n e r )   {   
             r e t u r n   e v l i s t e n e r . l e n g t h ;   
         }   
     }   
   
     r e t u r n   0 ;   
 }   
   
 / /   A b o u t   1 . 5 x   f a s t e r   t h a n   t h e   t w o - a r g   v e r s i o n   o f   A r r a y # s p l i c e ( ) .   
 f u n c t i o n   s p l i c e O n e ( l i s t ,   i n d e x )   {   
     f o r   ( v a r   i   =   i n d e x ,   k   =   i   +   1 ,   n   =   l i s t . l e n g t h ;   k   <   n ;   i   + =   1 ,   k   + =   1 )   
         l i s t [ i ]   =   l i s t [ k ] ;   
     l i s t . p o p ( ) ;   
 }   
   
 f u n c t i o n   a r r a y C l o n e ( a r r ,   i )   {   
     v a r   c o p y   =   n e w   A r r a y ( i ) ;   
     w h i l e   ( i - - )   
         c o p y [ i ]   =   a r r [ i ] ;   
     r e t u r n   c o p y ;   
 }   
 
 } ) ;  Q  D   ��
 N O D E _ M O D U L E S / F S . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / * *   
   *   S y N o d e   f i l e - s y s t e m   r o u t i n e s .   W e   t r y   t o   i m p l e m e n t   h e r e   t h e   s a m e   i n t e r f a c e   a s   i n   < a   h r e f = " h t t p : / / n o d e j s . o r g / a p i / f s . h t m l " > N o d e J S   f s < / a >   
   *   
   *             v a r   f s   =   r e q u i r e ( ' f s ' ) ;   
   *             v a r   c o n t e n t   =   f s . r e a d F i l e S y n c ( ' c : \ \ a . t x t ' ,   ' u t f - 8 ) ;   
   *   
   *   @ m o d u l e   f s   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 c o n s t   c o n s t a n t s   =   p r o c e s s . b i n d i n g ( ' c o n s t a n t s ' ) . f s   
 c o n s t   i n t e r n a l F S   =   r e q u i r e ( ' i n t e r n a l / f s ' )   
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' )   
 c o n s t   f s   =   e x p o r t s ;   
 c o n s t   { f i l e S t a t ,   d i r e c t o r y E x i s t s ,   f i l e E x i s t s ,   r e a d D i r ,   
     r e a l p a t h ,   r e n a m e ,   l o a d F i l e T o B u f f e r ,   
     w r i t e F i l e ,   a p p e n d F i l e ,   
     d e l e t e F i l e ,   f o r c e D i r e c t o r i e s ,   r e m o v e D i r ,   
 }   =   p r o c e s s . b i n d i n g ( ' f s ' )   
 c o n s t   p a t h M o d u l e   =   r e q u i r e ( ' p a t h ' ) ;   
 c o n s t   {   
     a s s e r t E n c o d i n g ,   
     s t r i n g T o F l a g s   
 }   =   i n t e r n a l F S ;   
   
 O b j e c t . d e f i n e P r o p e r t y ( e x p o r t s ,   ' c o n s t a n t s ' ,   {   
     c o n f i g u r a b l e :   f a l s e ,   
     e n u m e r a b l e :   t r u e ,   
     v a l u e :   c o n s t a n t s   
 } )   
   
 c o n s t   k M i n P o o l S p a c e   =   1 2 8 ;   
 c o n s t   {   k M a x L e n g t h   }   =   r e q u i r e ( ' b u f f e r ' )   
   
 c o n s t   i s W i n d o w s   =   p r o c e s s . p l a t f o r m   = = =   ' w i n 3 2 '   
   
 f u n c t i o n   g e t O p t i o n s ( o p t i o n s ,   d e f a u l t O p t i o n s )   {   
     i f   ( o p t i o n s   = = =   n u l l   | |   o p t i o n s   = = =   u n d e f i n e d   | |   
             t y p e o f   o p t i o n s   = = =   ' f u n c t i o n ' )   {   
         r e t u r n   d e f a u l t O p t i o n s ;   
     }   
   
     i f   ( t y p e o f   o p t i o n s   = = =   ' s t r i n g ' )   {   
         d e f a u l t O p t i o n s   =   u t i l . _ e x t e n d ( { } ,   d e f a u l t O p t i o n s ) ;   
         d e f a u l t O p t i o n s . e n c o d i n g   =   o p t i o n s ;   
         o p t i o n s   =   d e f a u l t O p t i o n s ;   
     }   e l s e   i f   ( t y p e o f   o p t i o n s   ! = =   ' o b j e c t ' )   {   
         t h r o w   n e w   T y p e E r r o r ( ' " o p t i o n s "   m u s t   b e   a   s t r i n g   o r   a n   o b j e c t ,   g o t   '   +   
                                                 t y p e o f   o p t i o n s   +   '   i n s t e a d . ' ) ;   
     }   
   
     i f   ( o p t i o n s . e n c o d i n g   ! = =   ' b u f f e r ' )   
         a s s e r t E n c o d i n g ( o p t i o n s . e n c o d i n g ) ;   
     r e t u r n   o p t i o n s ;   
 }   
   
 f u n c t i o n   n u l l C h e c k ( p a t h ,   c a l l b a c k )   {   
     i f   ( ( ' '   +   p a t h ) . i n d e x O f ( ' \ u 0 0 0 0 ' )   ! = =   - 1 )   {   
         v a r   e r   =   n e w   E r r o r ( ' P a t h   m u s t   b e   a   s t r i n g   w i t h o u t   n u l l   b y t e s ' ) ;   
         e r . c o d e   =   ' E N O E N T ' ;   
         / /   S y N o d e   i f   ( t y p e o f   c a l l b a c k   ! = =   ' f u n c t i o n ' )   
             t h r o w   e r ;   
         / /   S y N o d e   p r o c e s s . n e x t T i c k ( c a l l b a c k ,   e r ) ;   
         / /   S y N o d e   r e t u r n   f a l s e ;   
     }   
     r e t u r n   t r u e ;   
 }   
   
   
 / * *   
   *   C h e c k   s p e c i f i e d   p a t h   i s   f i l e   ( o r   s y m l y n k   t o   f i l e )   
   *   @ p a r a m   p a t h   
   *   @ r e t u r n   { B o o l e a n }   
   * /   
 e x p o r t s . i s F i l e     =   f u n c t i o n   i s F i l e ( p a t h ) {   
         r e t u r n   f i l e E x i s t s ( p a t h ) ;   
 } ;   
   
 / * *   
   *   C h e c k   s p e c i f i e d   p a t h   i s   f o l d e r   ( o r   s y m l y n k   t o   f o l d e r )   
   *   @ p a r a m   p a t h   
   *   @ r e t u r n   { B o o l e a n }   
   * /   
 e x p o r t s . i s D i r   =   f u n c t i o n   i s D i r ( p a t h ) {   
         r e t u r n   d i r e c t o r y E x i s t s ( p a t h ) ;   
 } ;   
   
 c o n s t   e m p t y O b j   =   O b j e c t . c r e a t e ( n u l l ) ;   
 / * *   
   *   S y n c h r o n o u s   r e a l p a t h ( 3 ) .   R e t u r n s   t h e   r e s o l v e d   p a t h   ( r e s o l v e   s y m l i n k s ,   j u n c t i o n s   o n   W i n d o w s ,   / . . / )   
   * /   
 e x p o r t s . r e a l p a t h S y n c   =   f u n c t i o n   r e a l p a t h S y n c ( p ,   o p t i o n s ) {   
     i f   ( ! o p t i o n s )   
         o p t i o n s   =   e m p t y O b j ;   
     e l s e   
         o p t i o n s   =   g e t O p t i o n s ( o p t i o n s ,   e m p t y O b j ) ;   
     i f   ( t y p e o f   p   ! = =   ' s t r i n g ' )   {   
         / /   S y N o d e   h a n d l e E r r o r ( ( p   =   g e t P a t h F r o m U R L ( p ) ) ) ;   
         / /   S y N o d e   i f   ( t y p e o f   p   ! = =   ' s t r i n g ' )   
             p   + =   ' ' ;   
     }   
     n u l l C h e c k ( p ) ;   
     p   =   p a t h M o d u l e . r e s o l v e ( p ) ;   
   
     c o n s t   c a c h e   =   o p t i o n s [ i n t e r n a l F S . r e a l p a t h C a c h e K e y ] ;   
     c o n s t   m a y b e C a c h e d R e s u l t   =   c a c h e   & &   c a c h e . g e t ( p ) ;   
     i f   ( m a y b e C a c h e d R e s u l t )   {   
         r e t u r n   m a y b e C a c h e d R e s u l t ;   
     }   
     l e t   r e s   =   r e a l p a t h ( p ) ;   
     i f   ( c a c h e )   c a c h e . s e t ( p ,   r e s ) ;   
     r e t u r n   r e s ;   
 } ;   
   
 / * *   
   *   R e a d s   t h e   e n t i r e   c o n t e n t s   o f   a   T E X T   f i l e .   
   *   I f   B O M   f o u n d   -   d e c o d e   t e x t   f i l e   t o   s t r i n g   u s i n g   B O M   
   *   I f   B O M   n o t   f o u n d   -   u s e   f o r c e U F T 8   p a r a m e t e r .   
   *   @ p a r a m   { S t r i n g }   f i l e N a m e   
   *   @ p a r a m   { B o o l e a n }   [ f o r c e U F T 8 ]   I f   n o   B O M   f o u n d   a n d   f o r c e U F T 8   i s   T r u e   ( d e f a u l t )   -   w e   e x p e c t   f i l e   i n   U T F 8   f o r m a t ,   e l s e   i n   a s c i i   
   *   @ r e t u r n s   { S t r i n g }   
   * /   
 e x p o r t s . l o a d F i l e   =   f u n c t i o n   ( f i l e N a m e ,   f o r c e U F T 8 ) {   
         r e t u r n   l o a d F i l e ( f i l e N a m e ,   f o r c e U F T 8 ) ;   
 } ;   
   
 / * *   
   *   R e a d s   t h e   e n t i r e   c o n t e n t s   o f   a   f i l e .   I f   o p t i o n s . e n c o d i n g   = =   ' b i n ' ,   t h e n   t h e   A r r a y B u f f e r   i s   r e t u r n e d .   
   *   I f   n o   o p t i o n s   i s   s p e c i f i e d   a t   a l l   -   r e s u l t   i s   S t r i n g   a s   i n   { @ l i n k   f s . l o a d F i l e }   
   *   @ p a r a m   { S t r i n g }   f i l e N a m e     A b s o l u t e   p a t h   t o   f i l e   
   *   @ p a r a m   { O b j e c t }   [ o p t i o n s ]   
   *   @ p a r a m   { S t r i n g | N u l l }   [ o p t i o n s . e n c o d i n g ]   D e f a u l t   t o   n u l l .   P o s s i b l e   v a l u e s :   ' b i n ' | ' a s c i i ' | ' u t f - 8 '   
   *   @ r e t u r n s   { S t r i n g | A r r a y B u f f e r }   
   * /   
 f u n c t i o n   r e a d F i l e S y n c ( f i l e N a m e ,   o p t i o n s ) {   
       l e t   s t a t   =   f i l e S t a t ( f i l e N a m e ) ;   
       i f   ( ! s t a t )   {   
             t h r o w   n e w   E r r o r ( ' n o   s u c h   f i l e   o r   d i r e c t o r y ,   o p e n   \ ' '   +   f i l e N a m e   +   ' \ ' ' ) ;   
       }   
       i f   ( ! o p t i o n s   | |   ( o p t i o n s   & &   ( o p t i o n s . e n c o d i n g   ! = =   ' b i n ' ) ) )   {   
             o p t i o n s   =   g e t O p t i o n s ( o p t i o n s ,   { f l a g :   ' r ' } ) ;   
       }   
   
       i f   ( o p t i o n s . e n c o d i n g   & &   ( ( o p t i o n s . e n c o d i n g   = = =   ' a s c i i ' )   | |   ( o p t i o n s . e n c o d i n g   = = =   ' u t f 8 ' )   | |   ( o p t i o n s . e n c o d i n g   = = =   ' u t f - 8 ' ) ) )   {   
               r e t u r n   l o a d F i l e ( f i l e N a m e ,   ! ( o p t i o n s . e n c o d i n g   = = =   ' a s c i i ' ) ) ;   
       }   e l s e   {   
               l e t   b u f   =   l o a d F i l e T o B u f f e r ( f i l e N a m e )   / /   U I n t 8 A r r a y   
               i f   ( o p t i o n s . e n c o d i n g   = = =   ' b i n ' )   r e t u r n   b u f   / /   u b   4 . x   c o m p a t i b i l i t y   m o d e   
               b u f   =   B u f f e r . f r o m ( b u f )   
               i f   ( o p t i o n s . e n c o d i n g )   
               b u f   =   b u f . t o S t r i n g ( o p t i o n s . e n c o d i n g ) ;   
               r e t u r n   b u f ;   
       }   
 } ;   
 e x p o r t s . r e a d F i l e S y n c   =   r e a d F i l e S y n c   
   
 f u n c t i o n   r e t h r o w ( )   {   
     r e t u r n   f u n c t i o n ( e r r )   {   
         i f   ( e r r )   {   
             t h r o w   e r r ;     
         }   
     } ;   
 }   
   
 f u n c t i o n   m a y b e C a l l b a c k ( c b )   {   
     r e t u r n   t y p e o f   c b   = = =   ' f u n c t i o n '   ?   c b   :   r e t h r o w ( ) ;   
 }   
   
 f u n c t i o n   m a k e O n e A r g F u n c A s y n c ( o n e A r g S y n c F u n c ) {   
     r e t u r n   f u n c t i o n ( a r g ,   c b ) {   
 	       v a r   _ r e s ;   
 	       v a r   c a l l b a c k   =   m a y b e C a l l b a c k ( c b ) ;   
 	       t r y   {   
 	 	     _ r e s   =   o n e A r g S y n c F u n c ( a r g ) ;   
 	 	     c a l l b a c k ( n u l l ,   _ r e s ) ;   
 	       }   c a t c h ( e ) {   
 	 	 	 c a l l b a c k ( e ) ;   
 	       } 	 	   
       }       	       
 } 	   
 e x p o r t s . r e a d F i l e   =   f u n c t i o n   r e a d F i l e ( f i l e N a m e ,   o p t i o n s ,   c a l l b a c k _ ) {   
       v a r   s t a t   =   f i l e S t a t ( f i l e N a m e ) ;   
       v a r   c a l l b a c k   =   m a y b e C a l l b a c k ( a r g u m e n t s [ a r g u m e n t s . l e n g t h   -   1 ] ) ;   
       i f   ( ! s t a t )   {   
               c a l l b a c k ( n e w   E r r o r ( ' n o   s u c h   f i l e   o r   d i r e c t o r y ,   o p e n   \ ' '   +   f i l e N a m e   +   ' \ ' ' ) ) ;   
       }   e l s e   {   
               c a l l b a c k ( n u l l ,   r e a d F i l e S y n c ( f i l e N a m e ,   o p t i o n s ) )   
       }   
 } ;   
   
 / / n o i n s p e c t i o n   J S U n u s e d L o c a l S y m b o l s   
 / * *   
   *   C r e a t e   a l l   m i s s i n g   f o l d e r s   i n   t h e   g i v e n   p a t h .   O n l y   a b s o l u t e   p a t h   s u p p o r t e d .   T h r o w   e r r o r   i n   c a s e   o f   f a i l   
   *   @ p a r a m   { S t r i n g }   p a t h   p a t h   f o r   c r e a t i o n .   
   *   @ p a r a m   { N u m b e r }   [ m o d e ]   I g n o r e d   u n d e r   W i n d o w s   
   * /   
 e x p o r t s . m k d i r S y n c   =   f u n c t i o n   m k d i r S y n c ( p a t h ,   m o d e ) {   
         i f   ( ! f o r c e D i r e c t o r i e s ( p a t h ) ) {   
                 t h r o w   n e w   E r r o r ( ' c a n \ ' t   c r e a t e   d i r e c t o r y   '   +   p a t h ) ;   
         }   
 } ;   
   
 / * *   R e a d   f i l e   n a m e s   f r o m   d i r e c t o r y   ( i n c l u d e   f o l d e r   n a m e s ) .   
   *   R e t u r n   a r r a y   o f   f i l e   n a m e s .   I n   c a s e   d i r e c t o r y   n o t   e x i s t s   -   t h r o w   e r r o r   
   *   @ p a r a m   { S t r i n g }   p a t h   
   *   @ r e t u r n   { A r r a y . < S t r i n g > }   
   * /   
 f u n c t i o n   r e a d d i r S y n c ( p a t h ) {   
         v a r   r e s   =   r e a d D i r ( p a t h ,   t r u e ) ;   
         i f   ( r e s   = =   n u l l )   {   
                 t h r o w   n e w   E r r o r ( ' c a n   n o t   r e a d   d i r   '   +   p a t h ) ;   
         }   e l s e   {   
                 r e t u r n   r e s ;   
         }   
 } ;   
 e x p o r t s . r e a d d i r S y n c   =   r e a d d i r S y n c ;     
   
 e x p o r t s . r e a d d i r   =   m a k e O n e A r g F u n c A s y n c ( r e a d d i r S y n c ) ;   
   
 / * *   
   *   G e t   f i l e   s t a t i s t i c s .   W i l l   t h r o w   i n   c a s e   f i l e   o r   f o l d e r   d o e s   n o t   e x i s t s .   
   *   @ p a r a m   f i l e N a m e   
   *   @ r e t u r n s   { B o o l e a n | { a t i m e :   D a t e ,   m t i m e :   D a t e ,   c t i m e :   D a t e ,   s i z e :   n u m b e r ,   _ f i l e N a m e :   s t r i n g ,   i s D i r e c t o r y :   f u n c t i o n } }   
   * /   
 f u n c t i o n   s t a t S y n c ( f i l e N a m e ) {   
         v a r   o S t a t ;   
   
         o S t a t   =   f i l e S t a t ( f i l e N a m e ) ;   
         i f   ( o S t a t   = = =   n u l l )   t h r o w   n e w   E r r o r ( ' E N O E N T :   n o   s u c h   f i l e   o r   d i r e c t o r y ,   s t a t   '   +   f i l e N a m e )   
         o S t a t . _ f i l e N a m e   =   f i l e N a m e ;   
         o S t a t . i s D i r e c t o r y   =   f u n c t i o n ( ) {   
             r e t u r n   f s . i s D i r ( t h i s . _ f i l e N a m e ) ;   
         } ;   
 	     o S t a t . i s F i l e   =   f u n c t i o n ( ) {   
             r e t u r n   ! f s . i s D i r ( t h i s . _ f i l e N a m e ) ;   
         } ;   
         o S t a t . i s S y m b o l i c L i n k   =   f u n c t i o n ( ) {   
                 r e t u r n   f a l s e ;   / / T O D O   -   i m p l e m e n t   
         } ;   
         r e t u r n   o S t a t ;   
 } ;   
   
 e x p o r t s . s t a t S y n c   =   s t a t S y n c ;   
   
 e x p o r t s . l s t a t S y n c   =   s t a t S y n c ;   
   
 e x p o r t s . s t a t   =   f u n c t i o n   s t a t ( f i l e N a m e ,   c a l l b a c k _ ) {   
       v a r   _ s t a t   
       v a r   c a l l b a c k   =   m a y b e C a l l b a c k ( a r g u m e n t s [ a r g u m e n t s . l e n g t h   -   1 ] ) ;   
       t r y   {   
           _ s t a t   =   s t a t S y n c ( f i l e N a m e ) ;   
           c a l l b a c k ( n u l l ,   _ s t a t ) ;   
       }   c a t c h   ( e )   {   
           c a l l b a c k ( e ) ;   
       }   
 } ;   
   
 / / t o d o   -   l s t a t   i s   a   f o l l o w S y m L y n c   v e r s i o n   o f   s t a t   
 e x p o r t s . l s t a t   =   e x p o r t s . s t a t ;   
   
 / * *   
   *   W r i t e   t o   f i l e   
   *   A c t u a l l y   i m p l e m e n t s   { @ l i n k   U B W r i t e r # w r i t e }   
   *   @ p a r a m   { S t r i n g }   f i l e N a m e     F u l l   a b s o l u t e   f i l e   p a t h   
   *   @ p a r a m   { A r r a y B u f f e r | O b j e c t | S t r i n g }   d a t a   D a t a   t o   w r i t e .   I f   O b j e c t   -   i t   s t r i n g i f y   b e f o r e   w r i t e   
   *   @ p a r a m   { O b j e c t }   [ o p t i o n s ]   
   *   @ p a r a m   { S t r i n g }   [ o p t i o n s . e n c o d i n g ]   E n c o d e   d a t a   t o   ` e n c o d i n g `   b e f o r e   w r i t e .   D e f a u l t   t o   ` u t f - 8 `   i n   c a s e   d a t a   i s   S t r i n g   o r   ` b i n `   i n   c a s e   d a t a   i s   A r r a y B u f f e r .   
   *                                                             O n e   o f   " u t f - 8 " | " u c s 2 " | " b i n " | " b a s e 6 4 " .   
   * /   
 e x p o r t s . w r i t e F i l e S y n c   =   f u n c t i o n   w r i t e F i l e S y n c ( f i l e N a m e ,   d a t a ,   o p t i o n s ) {   
         / / v a r   r e s   =   w r i t e F i l e ( f i l e N a m e ,   d a t a ) ;   
         v a r   
                 e n c o d i n g   =   o p t i o n s   & &   o p t i o n s . e n c o d i n g ,   
                 r e s ;   
         r e s   =   e n c o d i n g   ?   w r i t e F i l e ( f i l e N a m e ,   d a t a ,   e n c o d i n g )   :   w r i t e F i l e ( f i l e N a m e ,   d a t a ) ;   
         i f ( ! r e s )   
                 t h r o w   n e w   E r r o r ( ' c a n   n o t   w r i t e   f i l e   '   +   f i l e N a m e ) ;   
         e l s e   r e t u r n   r e s ;   
 } ;   
   
 / * *   
   *   A p p e n d   d a t a   t o   a   f i l e ,   c r e a t i n g   t h e   f i l e   i f   i t   n o t   y e t   e x i s t s   
   *   A c t u a l l y   i m p l e m e n t   { U B W r i t e r # w r i t e }   
   *   @ p a r a m   { S t r i n g }   f i l e N a m e     F u l l   a b s o l u t e   f i l e   p a t h   
   *   @ p a r a m   { A r r a y B u f f e r | O b j e c t | S t r i n g }   d a t a   D a t a   t o   w r i t e .   ` O b j e c t `   a r e   s t r i n g i f i e d   b e f o r e   w r i t e   
   *   @ p a r a m   { O b j e c t }   [ o p t i o n s ]   
   *   @ p a r a m   { S t r i n g }   [ o p t i o n s . e n c o d i n g ]   E n c o d e   d a t a   t o   ` e n c o d i n g `   b e f o r e   w r i t e .   
   *     D e f a u l t   t o   ` u t f - 8 `   i n   c a s e   d a t a   i s   S t r i n g   o r   ` b i n `   i n   c a s e   d a t a   i s   A r r a y B u f f e r .   
   *     P o s s i b l e   v a l u e s :   " u t f - 8 " | " u c s 2 " | " b i n " | " b a s e 6 4 " .   
   * /   
 e x p o r t s . a p p e n d F i l e S y n c   =   f u n c t i o n   a p p e n d F i l e S y n c ( f i l e N a m e ,   d a t a ,   o p t i o n s ) {   
         v a r   
                 e n c o d i n g   =   o p t i o n s   & &   o p t i o n s . e n c o d i n g ,   
                 r e s ;   
         r e s   =   e n c o d i n g   ?   a p p e n d F i l e ( f i l e N a m e ,   d a t a ,   e n c o d i n g )   :   a p p e n d F i l e ( f i l e N a m e ,   d a t a ) ;   
         i f ( ! r e s )   
                 t h r o w   n e w   E r r o r ( ' c a n   n o t   w r i t e   f i l e   '   +   f i l e N a m e ) ;   
         e l s e   r e t u r n   r e s ;   
 } ;   
   
 / * *   
   *   C h e c k   ` p a t h `   e x i s t s   ( c a n   b e   f i l e ,   f o l d e r   o r   s y m l y n c )   
   *   @ p a r a m   p a t h   
   *   @ r e t u r n   { B o o l e a n }   
   * /   
 e x p o r t s . e x i s t s S y n c   =   f u n c t i o n   e x i s t s S y n c ( p a t h ) {   
         r e t u r n   ! ! f i l e S t a t ( p a t h ) ;   
 } ;   
   
 / * *   
   *   D e l e t e   f i l e .   
   * /   
 f u n c t i o n   u n l i n k S y n c ( p a t h ) {   
         t r y {   
                 r e t u r n   d e l e t e F i l e ( p a t h )   
         } c a t c h ( e ) {   
                 r e t u r n   f a l s e ;   
         }   
 } ;   
 e x p o r t s . u n l i n k S y n c   =   u n l i n k S y n c ;     
   
 e x p o r t s . u n l i n k   =   m a k e O n e A r g F u n c A s y n c ( u n l i n k S y n c ) ;   
   
 / * *   
   *   D e l e t e   n o n - e m p t y   d i r e c t o r y .   S e e   { @ l i n k   r e m o v e D i r }   f o r   d e t a i l s   
   *   @ p a r a m   { S t r i n g }   p a t h   p a t h   t o   r e m o v e   
   * /   
 e x p o r t s . r m d i r S y n c   =   f u n c t i o n   r m d i r S y n c ( p a t h ) {   
         r e t u r n   r e m o v e D i r ( p a t h ) ;   
 } ;   
   
 / * *   
   *   M o v e   ( r e n a m e )   f i l e .   
   *   @ p a r a m   { S t r i n g }   o l d P a t h   
   *   @ p a r a m   { S t r i n g }   n e w P a t h   
   * /   
 e x p o r t s . r e n a m e S y n c   =   f u n c t i o n   r e n a m e S y n c ( o l d P a t h ,   n e w P a t h ) {   
     n u l l C h e c k ( o l d P a t h ) ;   
     n u l l C h e c k ( n e w P a t h ) ;   
     r e t u r n   r e n a m e ( p a t h M o d u l e . _ m a k e L o n g ( o l d P a t h ) ,   
         p a t h M o d u l e . _ m a k e L o n g ( n e w P a t h ) ) ;   
 } ;   
   
 / * *   
   *   F a k e   c l a s s   f o r   n o d e J S   c o m p a t i b i l i t y   
   * /   
 e x p o r t s . R e a d S t r e a m   =   R e a d S t r e a m ;   
 f u n c t i o n   R e a d S t r e a m ( ) { } 
 } ) ; T�  H   ��
 N O D E _ M O D U L E S / H T T P . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / * *   
   *   H T T P   c l i e n t .   
   *   @ e x a m p l e   
   *   
   v a r   h t t p   =   r e q u i r e ( ' h t t p ' ) ;   
   v a r   r e q u e s t   =   h t t p . r e q u e s t ( {   
         / / a l t e r n a t i v e   t o   h o s t / p o r t / p a t h   i s   
         / / U R L :   ' h t t p : / / l o c a l h o s t : 8 8 8 / g e t A p p I n f o ' ,   
         h o s t :   ' l o c a l h o s t ' ,   p o r t :   ' 8 0 ' ,   p a t h :   ' / g e t A p p I n f o ' ,   
         m e t h o d :   ' P O S T ' ,   
         s e n d T i m e o u t :   3 0 0 0 0 ,   r e c e i v e T i m e o u t :   3 0 0 0 0 ,   
         k e e p A l i v e :   t r u e ,   
         c o m p r e s s i o n E n a b l e :   t r u e   
   } ) ;   
   r e q u e s t . w r i t e ( ' A d d   s t r i n g   t o   r e s p o n s e ' ) ;   
   v a r   f i l e C o n t e n t   =   f s . r e a d F i l e S y n c ( ' d : \ b i n a r y F i l e . t x t ' ) ;   / /   r e t u r n   A r r a y B u f f e r ,   s i n c e   e n c o d i n g   n o t   p a s s e d   
   r e q u e s t . w r i t e ( f i l e C o n t e n t ,   ' b a s e 6 4 ' ) ;   / /   w r i t e   f i l e   c o n t e n t   a s   b a s e 6 4   e n c o d e d   s t r i n g   
   v a r   r e s p o n s e   =   r e q u e s t . e n d ( ) ;   
   
   v a r   h t t p   =   r e q u i r e ( ' h t t p ' ) ;   
   v a r   a s s e r t   =   r e q u i r e ( ' a s s e r t ' ) ;   
   v a r   D O M P a r s e r   =   r e q u i r e ( ' x m l d o m ' ) . D O M P a r s e r ;   
   / /   s e t   g l o b a l   p r o x y   s e t t i n g s   i f   c l i e n t   i s   b e h i n d   a   p r o x y   
   / /   h t t p . s e t G l o b a l P r o x y C o n f i g u r a t i o n ( ' p r o x y . m a i n : 3 2 4 9 ' ,   ' l o c a l h o s t ' ) ;   
   v a r   r e s p   =   h t t p . g e t ( ' h t t p s : / / s y n o p s e . i n f o / f o s s i l / w i k i / S y n o p s e + O p e n S o u r c e ' ) ;   
   / /   c h e c k   w e   a r e   a c t u a l l y   b e h i n d   a   p r o x y   
   / /   a s s e r t . o k ( r e s p . h e a d e r s ( ' v i a ' ) . s t a r t s W i t h ( ' 1 . 1   p r o x y . m a i n ' ) ,   ' p r o x y   u s e d ' ) ;   
   v a r   i n d e x   =   r e s p . r e a d ( ) ;   
   c o n s o l e . l o g ( i n d e x ) ;   
   / /   v a r   d o c   =   n e w   D O M P a r s e r ( ) . p a r s e F r o m S t r i n g ( i n d e x ) ;   
   / /   a s s e r t . o k ( d o c . d o c u m e n t E l e m e n t . t e x t C o n t e n t . s t a r t s W i t h ( ' m O R M o t ' ) ,   ' g o t   m O R M o t   f r o m   m O R M o t ' ) ;   
   *   
   *   @ m o d u l e   h t t p   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
 c o n s t   C R L F   =   ' \ r \ n '   
 c o n s t   u r l   =   r e q u i r e ( ' u r l ' )   
 c o n s t   E v e n t E m i t t e r   =   r e q u i r e ( ' e v e n t s ' ) . E v e n t E m i t t e r   
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' )   
 c o n s t   T H T T P C l i e n t   =   p r o c e s s . b i n d i n g ( ' s y n o d e _ h t t p ' ) . T H T T P C l i e n t   
   
 / *   G l o b a l   h t t p   p r o x y   c o n f i g u r a t i o n .     
     D e f a u l t   v a l u e   f o r   p r o x y   s e r v e r   g e t t e d   f o r m   h t t p _ p r o x y   e n v i r o n m e n t   v a r i a b l e .   
     U n d e r   W i n d o w s   ( D o c k e r   f o r   W i n d o w s   f o r   e x a m p l e )   H T T P _ P R O X Y   i s   u s e d ,   s o   f a l l b a c k   t o   i t   a l s o   
 * /   
 v a r   
     p r o x y C o n f i g   =   {   
         s e r v e r :   p r o c e s s . e n v . h t t p _ p r o x y   | |   p r o c e s s . e n v . H T T P _ P R O X Y   | |   ' ' ,   
         b y p a s s :   ' '   
     } ,   
     c o n n e c t i o n D e f a u l t s   =   {   
         u s e H T T P S :   f a l s e ,   
         u s e C o m p r e s s i o n :   t r u e ,   
         k e e p A l i v e :   f a l s e ,   
         c o n n e c t T i m e o u t :   6 0 0 0 0 ,   
         s e n d T i m e o u t :   3 0 0 0 0 ,   
         r e c e i v e T i m e o u t :   3 0 0 0 0   
     }   
   
 / * *   
   *     C o n f i g u r e   g l o b a l   (   o n   t h e   ` h t t p `   m o d u l e   l e v e l )   p r o x y   s e r v e r   i n   c a s e   y o u   c a n ' t   c o n f i g u r e   i t   u s i n g   
   *     e i t h e r   * * ` p r o x y c f g . e x e   - u ` * *   o n   W i n d o w s   X P   o r   * * ` n e t s h   w i n h t t p   i m p o r t   p r o x y   s o u r c e = i e ` * *   f o r   o t h e r   w i n   v e r s i o n   
   *     o r   b y   p a s s   ` o p t i o n s . p r o x y N a m e `   p a r a m e t e r .   
   *   
   *     S e t t i n g s   a p p l i e d   o n l y   f o r     n e w l y   c r e a t e d   { C l i e n t R e q u e s t }   i n s t a n c e s .   
   *   
   *     S e e   f o r   d e t a i l s   < a   h r e f = " h t t p : / / m s d n . m i c r o s o f t . c o m / e n - u s / l i b r a r y / w i n d o w s / d e s k t o p / a a 3 8 3 9 9 6 ( v = v s . 8 5 ) . a s p x " > t h i s   M S   a r t i c l e < / a >   
   *   
   *   @ p a r a m   { S t r i n g }   p r o x y           n a m e   o f   t h e   p r o x y   s e r v e r   t o   u s e   i n   f o r m a t   ` [ [ h t t p | h t t p s ] : / / ] h o s t [ : p o r t ] `   F o r   e x a m p l e   ' h t t p : / / p r o x y . m y . d o m a i n : 3 2 4 9 '   
   *   @ p a r a m   { S t r i n g | A r r a y }   [ b y p a s s ]     s e m i c o l o n   d e l i m i t e d   l i s t   j r   a r r a y   o f   h o s t   n a m e s   o r   I P   a d d r e s s e s ,   o r   h o s t   m a s k s   o r   b o t h ,   t h a t   s h o u l d   n o t   b e   r o u t e d   t h r o u g h   t h e   p r o x y   
   * /   
 e x p o r t s . s e t G l o b a l P r o x y C o n f i g u r a t i o n   =   f u n c t i o n   s e t G l o b a l P r o x y C o n f i g u r a t i o n   ( p r o x y ,   b y p a s s )   {   
     p r o x y C o n f i g . p r o x y   =   p r o x y   | |   ' '   
     i f   ( A r r a y . i s A r r a y ( b y p a s s ) )   {   
         b y p a s s   =   b y p a s s . j o i n ( ' ; ' )   
     }   
     p r o x y C o n f i g . b y p a s s   =   b y p a s s   | |   ' '   
 }   
   
 / * *   
   *     O v e r r i d e   g l o b a l   (   o n   t h e   ` h t t p `   m o d u l e   l e v e l )   c o n n e c t i u o n   d e f a u l t s .   
   *   
   *     S e t t i n g s   a p p l i e d   o n l y   f o r     n e w l y   c r e a t e d   { C l i e n t R e q u e s t }   i n s t a n c e s .   
   *   
   *                     v a r   h t t p   =   r e q u i r e ( ' h t t p ' ) ;   
   *                     h t t p . s e t G l o b a l C o n n e c t i o n D e f a u l t s ( { r e c e i v e T i m e o u t :   6 0 0 0 0 } ) ;   / /   s e t   r e c e i v e   t i m e o u t   t o   6 0   s e c .   
   *   
   *   @ p a r a m   { O b j e c t }   d e f a u l t s   
   *   @ p a r a m   { B o o l e a n }   [ d e f a u l t s . u s e H T T P S = f a l s e ]   
   *   @ p a r a m   { B o o l e a n }   [ d e f a u l t s . u s e C o m p r e s s i o n = t r u e ]   S e n d   ' A c c e p t - e n c o d i n g :   g z i p '   h e a d e r   t o   s e r v e r   &   u n z i p   z i p p e r   r e s p o n s e s   
   *   @ p a r a m   { B o o l e a n }   [ d e f a u l t s . k e e p A l i v e = f a l s e ]   U s e   k e e p   A l i v e   H T T P   p r o t o c o l   f e a t u r e   i f   s e r v e r   s u p p o r t   i t .   
   *   @ p a r a m   { N u m b e r }   [ d e f a u l t s . s e n d T i m e o u t = 3 0 0 0 0 ]   S e n d   t i m e o u t   i n   m s .   
   *   @ p a r a m   { N u m b e r }   [ d e f a u l t s . r e c e i v e T i m e o u t = 3 0 0 0 0 ]   R e c e i v e   t i m e o u t   i n   m s .   
   *   @ p a r a m   { N u m b e r }   [ d e f a u l t s . c o n n e c t T i m e o u t = 6 0 0 0 0 ]   C o n n e c t   t i m e o u t   i n   m s .   
   * /   
 e x p o r t s . s e t G l o b a l C o n n e c t i o n D e f a u l t s   =   f u n c t i o n   s e t G l o b a l C o n n e c t i o n D e f a u l t s   ( d e f a u l t s )   {   
     d e f a u l t s   =   d e f a u l t s   | |   { }   
     O b j e c t . k e y s ( c o n n e c t i o n D e f a u l t s ) . f o r E a c h ( f u n c t i o n   ( k e y )   {   
         i f   ( d e f a u l t s . h a s O w n P r o p e r t y ( k e y ) )   {   
             c o n n e c t i o n D e f a u l t s [ k e y ]   =   d e f a u l t s [ k e y ]   
         }   
     } )   
 }   
   
 / * *   
   *   C r e a t e   n e w   H T T P   s e r v e r   c o n n e c t i o n .   I n   c a s e   s e r v e r   b e h i n d   t h e   p r o x y   -   s e e   { @ l i n k   h t t p . s e t G l o b a l P r o x y C o n f i g u r a t i o n }   f u n c t i o n .   
   *   @ p a r a m   { O b j e c t | S t r i n g }   o p t i o n s   E i t h e r   U R L   s t r i n g   i n   f o r m a t   ` p r o t o c o l : / / h o s t : p o r t / p a t h `   o r   c o n f i g   
   *   @ p a r a m   { S t r i n g }   [ o p t i o n s . U R L ]   S e r v i c e   U R L   i n   f o r m a t   ` p r o t o c o l : / / h o s t : p o r t / p a t h ` .   W i l l   o v e r r i d e   ` u s e H T T P S ` ,   ` s e r v e r ` ,   ` h o s t ` ,   ` p o r t `   a n d   ` p a t h `   i f   p a s s e d   
   *   @ p a r a m   { S t r i n g }   [ o p t i o n s . s e r v e r ]   D E P R E C A T E D .   S e r v e r   t o   c o n n e c t   i n   f o r m a t   ' h o s t : p o r t '   o r   ' h o s t '   i n   c a s e   p o r t   = =   8 0 .   
   *   @ p a r a m   { S t r i n g }   [ o p t i o n s . h o s t ]   H o s t   t o   c o n n e c t .   I f   ` s e r v e r `   n o t   s p e c i f i e d   t h i s   v a l u e   u s e d   
   *   @ p a r a m   { S t r i n g }   [ o p t i o n s . p o r t ]   P o r t .   D e f a u l t   i s   8 0   f o r   H T T P   o r   4 4 3   f o r   H T T P S   
   *   @ p a r a m   { S t r i n g }   [ o p t i o n s . p a t h = ' / ' ]   R e q u e s t   p a t h .   D e f a u l t s   t o   ' / ' .   S h o u l d   i n c l u d e   q u e r y   s t r i n g   i f   a n y .   E . G .   ' / i n d e x . h t m l ? p a g e = 1 2 '   
   *   @ p a r a m   { S t r i n g }   [ o p t i o n s . m e t h o d = ' G E T ' ]   H T T P   m e t h o d   t o   u s e   f o r   r e q u e s t   
   *   @ p a r a m   { O b j e c t < s t r i n g ,   s t r i n g > }   [ o p t i o n s . h e a d e r s ]   A n   o b j e c t   c o n t a i n i n g   r e q u e s t   h e a d e r s   
   *   @ p a r a m   { B o o l e a n }   [ o p t i o n s . u s e H T T P S = f a l s e ]   
   *   @ p a r a m   { B o o l e a n }   [ o p t i o n s . u s e C o m p r e s s i o n = t r u e ]   S e n d   ' A c c e p t - e n c o d i n g :   g z i p '   h e a d e r   t o   s e r v e r   &   u n z i p   z i p p e r   r e s p o n s e s   
   *   @ p a r a m   { B o o l e a n }   [ o p t i o n s . k e e p A l i v e = f a l s e ]   U s e   k e e p   A l i v e   H T T P   p r o t o c o l   f e a t u r e   i f   s e r v e r   s u p p o r t   i t .   
   *   @ p a r a m   { N u m b e r }   [ o p t i o n s . s e n d T i m e o u t = 3 0 0 0 0 ]   S e n d   t i m e o u t   i n   m s .   
   *   @ p a r a m   { N u m b e r }   [ o p t i o n s . r e c e i v e T i m e o u t = 3 0 0 0 0 ]   R e c e i v e   t i m e o u t   i n   m s .   
   *   @ p a r a m   { N u m b e r }   [ o p t i o n s . c o n n e c t T i m e o u t = 3 0 0 0 0 ]   C o n n e c t   t i m e o u t   i n   m s .   
   *   @ r e t u r n   { C l i e n t R e q u e s t }   
   * /   
 e x p o r t s . r e q u e s t   =   f u n c t i o n   r e q u e s t   ( o p t i o n s )   {   
     v a r   
                 p a r s e d U R L   
     i f   ( t y p e o f   o p t i o n s   = = =   ' s t r i n g ' )   {   
         o p t i o n s   =   u r l . p a r s e ( o p t i o n s )   
         o p t i o n s . h o s t   =   o p t i o n s . h o s t n a m e   
     }   e l s e   i f   ( o p t i o n s . U R L )   {   
         p a r s e d U R L   =   u r l . p a r s e ( o p t i o n s . U R L )   
         O b j e c t . a s s i g n ( o p t i o n s ,   p a r s e d U R L )   
         o p t i o n s . h o s t   =   o p t i o n s . h o s t n a m e   
     }   e l s e   i f   ( o p t i o n s . s e r v e r )   {   
         v a r   h o s t _ p o r t   =   o p t i o n s . s e r v e r . s p l i t ( ' : ' )   
         o p t i o n s . h o s t   =   h o s t _ p o r t [ 0 ]   
   
         o p t i o n s . p o r t   =   h o s t _ p o r t [ 1 ]   
     }   
     i f   ( ! o p t i o n s . h o s t )   {   
         t h r o w   n e w   E r r o r ( ' s e r v e r   h o s t   i s   m a n d a t o r y ' )   
     }   
     i f   ( ! o p t i o n s . h o s t n a m e )   {   o p t i o n s . h o s t n a m e   =   o p t i o n s . h o s t   }   
   
     o p t i o n s . p a t h   =   o p t i o n s . p a t h   | |   ' / '   
     i f   ( o p t i o n s . p a t h . c h a r A t ( 0 )   ! = =   ' / ' )   o p t i o n s . p a t h   =   ' / '   +   o p t i o n s . p a t h   / /   n e e d   v a l i d   u r l   a c c o r d i n g   t o   t h e   H T T P / 1 . 1   R F C   
     o p t i o n s . h e a d e r s   =   o p t i o n s . h e a d e r s   | |   { }   
     i f   ( o p t i o n s . p r o t o c o l )   {   
         o p t i o n s . u s e H T T P S   =   ( o p t i o n s . p r o t o c o l   = = =   ' h t t p s : ' )   
     }   e l s e   {   
         o p t i o n s . u s e H T T P S   =   o p t i o n s . u s e H T T P S   = =   n u l l   ?   c o n n e c t i o n D e f a u l t s . u s e H T T P S   :   o p t i o n s . u s e H T T P S   
     }   
     o p t i o n s . p o r t   =   o p t i o n s . p o r t   | |   ( o p t i o n s . u s e H T T P S   ?   ' 4 4 3 '   :   ' 8 0 ' )   
     o p t i o n s . u s e C o m p r e s s i o n   =   o p t i o n s . u s e C o m p r e s s i o n   = =   n u l l   ?   t r u e   :   o p t i o n s . u s e C o m p r e s s i o n   
     o p t i o n s . k e e p A l i v e   =   ( o p t i o n s . k e e p A l i v e   = = =   t r u e )   ?   1   :   c o n n e c t i o n D e f a u l t s . k e e p A l i v e   
     o p t i o n s . s e n d T i m e o u t   =   o p t i o n s . s e n d T i m e o u t   | |   c o n n e c t i o n D e f a u l t s . s e n d T i m e o u t   
     o p t i o n s . r e c e i v e T i m e o u t   =   o p t i o n s . r e c e i v e T i m e o u t   | |   c o n n e c t i o n D e f a u l t s . r e c e i v e T i m e o u t   
     o p t i o n s . c o n n e c t T i m e o u t   =   o p t i o n s . c o n n e c t T i m e o u t   | |   c o n n e c t i o n D e f a u l t s . c o n n e c t T i m e o u t   
     o p t i o n s . m e t h o d   =   o p t i o n s . m e t h o d   | |   ' G E T '   
     r e t u r n   n e w   C l i e n t R e q u e s t ( o p t i o n s )   
 }   
 v a r   r e q u e s t   =   e x p o r t s . r e q u e s t   
   
 f u n c t i o n   f o r E a c h S o r t e d   ( o b j ,   i t e r a t o r ,   c o n t e x t )   {   
     v a r   k e y s   =   O b j e c t . k e y s ( o b j ) . s o r t ( )   
     k e y s . f o r E a c h ( f u n c t i o n   ( k e y )   {   
         i t e r a t o r . c a l l ( c o n t e x t ,   o b j [ k e y ] ,   k e y )   
     } )   
     r e t u r n   k e y s   
 }   
   
 / * *   
   *   A d d   p a r a m e t e r s   t o   U R L   
   *   
   *             h t t p . b u i l d U R L ( ' / m y M e t h o d ' ,   { a :   1 ,   b :   " 1 2 1 2 " } ;   / /   ' / m y M e t h o d ? a = 1 & b = 1 2 1 2   
   *   
   *   @ p a r a m   { S t r i n g }   u r l   
   *   @ p a r a m   { O b j e c t }   p a r a m s   
   *   @ r e t u r n s   { S t r i n g }   
   * /   
 e x p o r t s . b u i l d U R L   =   f u n c t i o n   b u i l d U R L   ( u r l ,   p a r a m s )   {   
     i f   ( ! p a r a m s )   {   
         r e t u r n   u r l   
     }   
     v a r   p a r t s   =   [ ]   
     f o r E a c h S o r t e d ( p a r a m s ,   f u n c t i o n   ( v a l u e ,   k e y )   {   
         i f   ( v a l u e   = =   n u l l )   {   
             r e t u r n   
         }   
         i f   ( ! A r r a y . i s A r r a y ( v a l u e ) )   {   
             v a l u e   =   [ v a l u e ]   
         }   
   
         v a l u e . f o r E a c h ( f u n c t i o n   ( v )   {   
             i f   ( t y p e o f   v   = = =   ' o b j e c t ' )   {   
                 v   =   J S O N . s t r i n g i f y ( v )   
             }   
             p a r t s . p u s h ( e n c o d e U R I C o m p o n e n t ( k e y )   +   ' = '   +   e n c o d e U R I C o m p o n e n t ( v ) )   
         } )   
     } )   
     r e t u r n   u r l   +   ( ( u r l . i n d e x O f ( ' ? ' )   = =   - 1 )   ?   ' ? '   :   ' & ' )   +   p a r t s . j o i n ( ' & ' )   
 }   
   
 v a r   b u i l d U r l   =   e x p o r t s . b u i l d U R L   
   
 / * *   
   *   S i n c e   m o s t   r e q u e s t s   a r e   G E T   r e q u e s t s   w i t h o u t   b o d i e s ,   w e   p r o v i d e s   t h i s   c o n v e n i e n c e   m e t h o d .   
   *   T h e   t w o   d i f f e r e n c e   b e t w e e n   t h i s   m e t h o d   a n d   h t t p . r e q u e s t ( )   i s   t h a t   
   *   
   *       -   i t   s e t s   t h e   m e t h o d   t o   G E T   a n d   c a l l s   r e q . e n d ( )   a u t o m a t i c a l l y   
   *       -   c a n   o p t i o n a l l y   t a k e   U R L P a r a m s   O b j e c t   { p a r a m N a m e :   p a r a m V a l u e ,   . . }   a n d   a d d   p a r a m e t e r s   t o   r e q u e s t   p a t h   
   *   
   *   @ p a r a m   { O b j e c t }   o p t i o n s   R e q u e s t   o p t i o n s   a s   d e s c r i b e d   i n   { @ l i n k   h t t p . r e q u e s t }   
   *   @ p a r a m   { O b j e c t }   [ U R L P a r a m s ]   o p t i o n a l   p a r a m e t e r s   t o   a d d   t o   o p t i o n s . p a t h   
   *   @ r e t u r n s   { I n c o m i n g M e s s a g e }   
   * /   
 e x p o r t s . g e t   =   f u n c t i o n   g e t   ( o p t i o n s ,   U R L P a r a m s )   {   
     v a r   r e q   =   r e q u e s t ( o p t i o n s )   
     i f   ( U R L P a r a m s )   {   
         r e q . s e t P a t h ( b u i l d U r l ( r e q . o p t i o n s . p a t h ,   U R L P a r a m s ) )   
     }   
     r e q . s e t M e t h o d ( ' G E T ' )   
     r e t u r n   r e q . e n d ( )   
 }   
   
 / * *   
   *   T h i s   o b j e c t   i s   c r e a t e d   i n t e r n a l l y   a n d   r e t u r n e d   f r o m   { @ l i n k   h t t p . r e q u e s t }   
   *   I t   r e p r e s e n t s   a n   i n - p r o g r e s s   r e q u e s t   w h o s e   h e a d e r   h a s   a l r e a d y   b e e n   q u e u e d .   
   *   T h e   h e a d e r   i s   s t i l l   m u t a b l e   u s i n g   t h e   { @ l i n k   C l i e n t R e q u e s t . s e t H e a d e r   s e t H e a d e r ( n a m e ,   v a l u e ) } ,   
   *       { @ l i n k   C l i e n t R e q u e s t # g e t H e a d e r   g e t H e a d e r ( n a m e ) } ,   { @ l i n k   C l i e n t R e q u e s t # r e m o v e H e a d e r   r e m o v e H e a d e r ( n a m e ) }   A P I .   
   *   T h e   a c t u a l   h e a d e r   w i l l   b e   s e n t   a l o n g   w i t h   t h e   { @ l i n k   C l i e n t R e q u e s t # e n d   e n d ( ) } .   
   *   
   *   ` p a t h `   &   ` m e t h o d `   p a r a m e t e r   i s   s t i l l   m u t a b l e   u s i n g   { @ l i n k   C l i e n t R e q u e s t # s e t P a t h   s e t P a t h ( p a t h ) }   &   { @ l i n k   C l i e n t R e q u e s t # s e t M e t h o d   s e t M e t h o d ( H T T P M e t h o d ) }   
   
   *   @ c l a s s   C l i e n t R e q u e s t   
   *   @ i m p l e m e n t s   { U B W r i t e r }   
   *   @ p r o t e c t e d   
   *   @ p a r a m   { O b j e c t }   o p t i o n s   
   * /   
 f u n c t i o n   C l i e n t R e q u e s t   ( o p t i o n s )   {   
     t h i s . o p t i o n s   =   O b j e c t . a s s i g n ( { } ,   o p t i o n s )   
     c o n s t   _ h t t p   =   t h i s . c o n n e c t i o n   =   n e w   T H T T P C l i e n t ( )   
     _ h t t p . i n i t i a l i z e ( o p t i o n s . h o s t ,   o p t i o n s . p o r t ,   o p t i o n s . u s e H T T P S ,   o p t i o n s . u s e C o m p r e s s i o n ,   
                 p r o x y C o n f i g . p r o x y ,   p r o x y C o n f i g . b y p a s s ,   o p t i o n s . c o n n e c t T i m e o u t ,   o p t i o n s . s e n d T i m e o u t ,   o p t i o n s . r e c e i v e T i m e o u t   
         )   
     _ h t t p . k e e p A l i v e   =   o p t i o n s . k e e p A l i v e   ?   1   :   0   
   
         / /   a d d   E v e n t E m i t t e r   t o   p r o c e s s   o b j e c t   
     E v e n t E m i t t e r . c a l l ( t h i s )   
     u t i l . _ e x t e n d ( t h i s ,   E v e n t E m i t t e r . p r o t o t y p e )   
   
     O b j e c t . d e f i n e P r o p e r t y ( t h i s ,   ' p a t h ' ,   {   
         g e t :   f u n c t i o n   ( )   {   r e t u r n   t h i s . o p t i o n s . p a t h   } ,   
         s e t :   f u n c t i o n   ( v a l )   {   t h i s . o p t i o n s . p a t h   =   v a l   }   
     } )   
 }   
   
 / * *   
   *   W r i t e   a   c h u n k   o f   d a t a   t o   r e q u e s t .   A c t u a l   s e n d i n g   p e r f o r m e d   b y   ` e n d ( ) `   c a l l .   
   *   @ i n h e r i t D o c   
   * /   
 C l i e n t R e q u e s t . p r o t o t y p e . w r i t e   =   f u n c t i o n   ( d a t a ,   e n c o d i n g )   {   
     t h i s . c o n n e c t i o n . w r i t e ( d a t a ,   e n c o d i n g )   
 }   
   
 / * *   
   *   S e t   a l l   h e a d e r s   d e l i m i t e d   b y   C R L F   b y   o n c e   
   *   @ p a r a m   { S t r i n g }   a l l H e a d e r s   
   * /   
 C l i e n t R e q u e s t . p r o t o t y p e . s e t H e a d e r s A s S t r i n g   =   f u n c t i o n   ( a l l H e a d e r s )   {   
     t h i s . o p t i o n s . _ h e a d e r s A s S t r i n g   =   a l l H e a d e r s   
 }   
   
 f u n c t i o n   m a k e R e q u e s t H e a d e r s   ( r e q u e s t )   {   
     i f   ( r e q u e s t . o p t i o n s . _ h e a d e r s A s S t r i n g )   r e t u r n   r e q u e s t . o p t i o n s . _ h e a d e r s A s S t r i n g   
       
     l e t   a r r   =   [ ]   
     l e t   h e a d   =   r e q u e s t . o p t i o n s . h e a d e r s   
     f o r   ( l e t   p r o p   i n   h e a d )   {   
         a r r . p u s h ( p r o p   +   ' :   '   +   h e a d [ p r o p ] )   
     }   
     r e t u r n   a r r . j o i n ( C R L F )   
 }   
 / * *   
   *   E n d   r e q u e s t   b y   w r i t i n g   a   l a s t   c h u n k   o f   d a t a   ( o p t i o n a l )   a n d   s e n d   r e q u e s t   t o   s e r v e r .   
   *   S e e   { @ l i n k   U B W r i t e r # w r i t e }   f o r   p a r a m e t e r s   
   *   @ r e t u r n s   { I n c o m i n g M e s s a g e }   
   * /   
 C l i e n t R e q u e s t . p r o t o t y p e . e n d   =   f u n c t i o n   ( d a t a ,   e n c o d i n g )   {   
     v a r   
         _ h t t p   =   t h i s . c o n n e c t i o n ,   
         r U l r   
     _ h t t p . w r i t e E n d ( d a t a ,   e n c o d i n g )   
     _ h t t p . m e t h o d   =   t h i s . o p t i o n s . m e t h o d   
     _ h t t p . h e a d e r s   =   m a k e R e q u e s t H e a d e r s ( t h i s )   
     t r y   {   
         _ h t t p . d o R e q u e s t ( t h i s . o p t i o n s . p a t h )   
     }   c a t c h   ( e )   {   
         r U l r   =   ( t h i s . o p t i o n s . p r o t o c o l   | |   ' h t t p : ' )   +   ' / / '   +   t h i s . o p t i o n s . h o s t n a m e   +   ' : '   +   t h i s . o p t i o n s . p o r t   +   t h i s . o p t i o n s . p a t h   
         t h r o w   n e w   E r r o r ( ' R e q u e s t   t o   '   +   r U l r   +   '   f a i l .   M e s s a g e :   '   +   e . m e s s a g e )   
     }   
     l e t   m s g   =   n e w   I n c o m i n g M e s s a g e ( _ h t t p )   
     i f   ( ! t h i s . e m i t ( ' r e s p o n s e ' ,   m s g )   | |   
                 ! m s g . e m i t ( ' d a t a ' ,   n e w   B u f f e r ( m s g . r e a d ( m s g . e n c o d i n g   = = =   ' b i n a r y '   ?   ' b i n '   :   m s g . e n c o d i n g   = = =   ' u t f 8 '   ?   ' u t f - 8 '   :   m s g . e n c o d i n g ) ) . t o S t r i n g ( m s g . e n c o d i n g ) )   | |   
                 ! m s g . e m i t ( ' e n d ' ) )   {   
         r e t u r n   m s g   
     }   
 }   
   
 / * *   
   *   S e t   n e w   p a t h   f o r   r e q u e s t .   U s u a l l y   u s e d   d u r i n g   s e v e r a l   r e q u e s t   t o   t h e   s a m e   s e r v e r   t o   a v o i d   s o c k e t   r e c r e a t i o n .   
   *   @ p a r a m   { S t r i n g }   p a t h   N e w   p a t h .   S h o u l d   i n c l u d e   q u e r y   s t r i n g   i f   a n y .   E . G .   ' / i n d e x . h t m l ? p a g e = 1 2 '   
   * /   
 C l i e n t R e q u e s t . p r o t o t y p e . s e t P a t h   =   f u n c t i o n   ( p a t h )   {   
     t h i s . o p t i o n s . p a t h   =   p a t h   
 }   
   
 / * *   
   *   S e t   n e w   H T T P   m e t h o d   f o r   r e q u e s t .   U s u a l l y   u s e d   d u r i n g   s e v e r a l   r e q u e s t   t o   t h e   s a m e   s e r v e r   t o   a v o i d   s o c k e t   r e c r e a t i o n .   
   *   @ p a r a m   { S t r i n g }   m e t h o d   
   * /   
 C l i e n t R e q u e s t . p r o t o t y p e . s e t M e t h o d   =   f u n c t i o n   ( m e t h o d )   {   
     t h i s . o p t i o n s . m e t h o d   =   m e t h o d   
 }   
   
 / * *   
   *   S e t s   a   s i n g l e   h e a d e r   v a l u e   f o r   i m p l i c i t   h e a d e r s .   
   *   I f   t h i s   h e a d e r   a l r e a d y   e x i s t s   i n   t h e   t o - b e - s e n t   h e a d e r s ,   i t s   v a l u e   w i l l   b e   r e p l a c e d .   
   *   U s e   a n   a r r a y   o f   s t r i n g s   h e r e   i f   y o u   n e e d   t o   s e n d   m u l t i p l e   h e a d e r s   w i t h   t h e   s a m e   n a m e   
   *   
   *             r e q u e s t . s e t H e a d e r ( ' C o n t e n t - T y p e ' ,   ' t e x t / h t m l ' ) ;   
   *             r e q u e s t . s e t H e a d e r ( ' S e t - C o o k i e ' ,   [ ' t y p e = n i n j a ' ,   ' l a n g u a g e = j a v a s c r i p t ' ] ) ;   
   *   
   *   @ p a r a m   { S t r i n g }   n a m e   
   *   @ p a r a m   { S t r i n g | A r r a y }   v a l u e   
   * /   
 C l i e n t R e q u e s t . p r o t o t y p e . s e t H e a d e r   =   f u n c t i o n   ( n a m e ,   v a l u e )   {   
     t h i s . o p t i o n s . h e a d e r s [ n a m e ]   =   A r r a y . i s A r r a y ( v a l u e )   ?   v a l u e . j o i n ( ' ; ' )   :   v a l u e   
 }   
   
 / * *   
   *   R e a d s   o u t   a   h e a d e r   t h a t ' s   a l r e a d y   b e e n   q u e u e d   b u t   n o t   s e n t   t o   t h e   c l i e n t .   
   *   @ p a r a m   { S t r i n g }   n a m e   
   *   @ r e t u r n s   { S t r i n g }   
   * /   
 C l i e n t R e q u e s t . p r o t o t y p e . g e t H e a d e r   =   f u n c t i o n   ( n a m e )   {   
     i f   ( a r g u m e n t s . l e n g t h   <   1 )   {   
         t h r o w   n e w   E r r o r ( ' ` n a m e `   i s   r e q u i r e d   f o r   g e t H e a d e r ( ) . ' )   
     }   
     r e t u r n   t h i s . o p t i o n s . h e a d e r s [ n a m e ]   
 }   
   
 / * *   
   *   R e m o v e s   a   h e a d e r   t h a t ' s   q u e u e d   f o r   i m p l i c i t   s e n d i n g   
   *   @ p a r a m   { S t r i n g }   n a m e   
   * /   
 C l i e n t R e q u e s t . p r o t o t y p e . r e m o v e H e a d e r   =   f u n c t i o n   ( n a m e )   {   
     i f   ( a r g u m e n t s . l e n g t h   <   1 )   {   
         t h r o w   n e w   E r r o r ( ' ` n a m e `   i s   r e q u i r e d   f o r   r e m o v e H e a d e r ( ) . ' )   
     }   
     d e l e t e   t h i s . o p t i o n s . h e a d e r s [ n a m e ]   
 }   
   
 / * *   
   *   R e s u l t   o f   H T T P   r e q u e s t   
   *   @ c l a s s   I n c o m i n g M e s s a g e   
   *   @ i m p l e m e n t s   { U B R e a d e r }   
   *   @ p a r a m   { T H T T P C l i e n t }   h t t p C l i e n t   
   *   @ p r o t e c t e d   
   * /   
 f u n c t i o n   I n c o m i n g M e s s a g e   ( h t t p C l i e n t )   {   
     t h i s . _ h t t p   =   h t t p C l i e n t   
         / * *   
           *   D e f a u l t   e n c o d i n g   f o r   r e a d   c a l l   
           *   @ t y p e   { S t r i n g }   
           * /   
     t h i s . e n c o d i n g   =   ' u t f - 8 '   
         / * *   @ p r i v a t e   * /   
     t h i s . _ p a r s e d H e a d e r s   =   n u l l   
         / * *   
           *   H T T P   s t a t u s   c o d e .   S e e   a l s o   { S T A T U S _ C O D E S }   
           *   @ t y p e   { N u m b e r }   
           *   @ r e a d o n l y   
           * /   
     t h i s . s t a t u s C o d e   =   t h i s . _ h t t p . r e s p o n s e S t a t u s   
   
         / /   a d d   E v e n t E m i t t e r   t o   I n c o m i n g M e s s a g e   o b j e c t   
     E v e n t E m i t t e r . c a l l ( t h i s )   
     u t i l . _ e x t e n d ( t h i s ,   E v e n t E m i t t e r . p r o t o t y p e )   
   
         / * *   
           *   R e s p o n s e   h e a d e r s ,   t r a n s f o r m e d   t o   J S   o b j e c t .   H e a d e r s   n a m e   i s   a   k e y s   i n   l o w e r   c a s e   
           * /   
     O b j e c t . d e f i n e P r o p e r t y ( t h i s ,   ' h e a d e r s ' ,   {   
         g e t :   ( )   = >   t h i s . _ p a r s e d H e a d e r s   ?   t h i s . _ p a r s e d H e a d e r s   :   t h i s . _ _ d o P a r s e H e a d e r s ( )   
     } )   
 }   
   
 / * *   
   *   C h a n g e   d e f a u l t   e n c o d i n g   f o r   r e a d   r e q u e s t   
   *   @ p a r a m   { S t r i n g }   e n c o d i n g   
   * /   
 I n c o m i n g M e s s a g e . p r o t o t y p e . s e t E n c o d i n g   =   f u n c t i o n   ( e n c o d i n g )   {   
     t h i s . e n c o d i n g   =   e n c o d i n g   
 }   
   
 / * *   
   *   R e a d   a   r e s p o n s e   b o d y .   S e e   { @ l i n k   U B R e a d e r # r e a d }   f o r   p a r a m e t e r s   
   *   @ p a r a m   { S t r i n g }   [ e n c o d i n g ]   I f   o m i t t e d   ` t h i s . e n c o d i n g `   i n   u s e d   
   * /   
 I n c o m i n g M e s s a g e . p r o t o t y p e . r e a d   =   f u n c t i o n   ( e n c o d i n g )   {   
     r e t u r n   t h i s . _ h t t p . r e a d ( e n c o d i n g   | |   t h i s . e n c o d i n g )   
 }   
   
 / * *   
   *   I n t e r n a l   f u n c t i o n   f o r   p a r s e   r e s p o n s e   h e a d e r s   
   *   T O D O   -   i m p r o v e   n o d e   c o m p a t i b i l i t y   -   s o m e   h e a d e r s   M U S T   m e   m e r g e d .   S e e   h t t p s : / / n o d e j s . o r g / a p i / h t t p . h t m l # h t t p _ m e s s a g e _ h e a d e r s   
   *   @ p r i v a t e   
   * /   
 I n c o m i n g M e s s a g e . p r o t o t y p e . _ _ d o P a r s e H e a d e r s   =   f u n c t i o n   ( )   {   
     v a r   
                 h ,   h O b j ,   h P a r t   
   
     i f   ( ! t h i s . _ p a r s e d H e a d e r s )   {   
         h   =   t h i s . _ h t t p . r e s p o n s e H e a d e r s . s p l i t ( C R L F )   
         h O b j   =   { }   
         h . f o r E a c h ( f u n c t i o n   ( h e a d e r )   {   
             i f   ( h e a d e r )   {   
                 h P a r t   =   h e a d e r . s p l i t ( ' :   ' ,   2 )   
                 i f   ( h P a r t . l e n g t h   =   2 )   {   h O b j [ h P a r t [ 0 ] . t o L o w e r C a s e ( ) ]   =   h P a r t [ 1 ]   }   
             }   
         } )   
         t h i s . _ p a r s e d H e a d e r s   =   h O b j   
     }   
   
     r e t u r n   t h i s . _ p a r s e d H e a d e r s   
 }   
   
 / * *   
   *   H T T P   s t a t u s   c o d e s .   
   *   @ t y p e   { O b j e c t . < n u m b e r ,   s t r i n g > }   
   * /   
 e x p o r t s . S T A T U S _ C O D E S   =   {   
     1 0 0 :   ' C o n t i n u e ' ,   
     1 0 1 :   ' S w i t c h i n g   P r o t o c o l s ' ,   
     1 0 2 :   ' P r o c e s s i n g ' ,                                   / /   R F C   2 5 1 8 ,   o b s o l e t e d   b y   R F C   4 9 1 8   
     2 0 0 :   ' O K ' ,   
     2 0 1 :   ' C r e a t e d ' ,   
     2 0 2 :   ' A c c e p t e d ' ,   
     2 0 3 :   ' N o n - A u t h o r i t a t i v e   I n f o r m a t i o n ' ,   
     2 0 4 :   ' N o   C o n t e n t ' ,   
     2 0 5 :   ' R e s e t   C o n t e n t ' ,   
     2 0 6 :   ' P a r t i a l   C o n t e n t ' ,   
     2 0 7 :   ' M u l t i - S t a t u s ' ,                               / /   R F C   4 9 1 8   
     3 0 0 :   ' M u l t i p l e   C h o i c e s ' ,   
     3 0 1 :   ' M o v e d   P e r m a n e n t l y ' ,   
     3 0 2 :   ' M o v e d   T e m p o r a r i l y ' ,   
     3 0 3 :   ' S e e   O t h e r ' ,   
     3 0 4 :   ' N o t   M o d i f i e d ' ,   
     3 0 5 :   ' U s e   P r o x y ' ,   
     3 0 7 :   ' T e m p o r a r y   R e d i r e c t ' ,   
     4 0 0 :   ' B a d   R e q u e s t ' ,   
     4 0 1 :   ' U n a u t h o r i z e d ' ,   
     4 0 2 :   ' P a y m e n t   R e q u i r e d ' ,   
     4 0 3 :   ' F o r b i d d e n ' ,   
     4 0 4 :   ' N o t   F o u n d ' ,   
     4 0 5 :   ' M e t h o d   N o t   A l l o w e d ' ,   
     4 0 6 :   ' N o t   A c c e p t a b l e ' ,   
     4 0 7 :   ' P r o x y   A u t h e n t i c a t i o n   R e q u i r e d ' ,   
     4 0 8 :   ' R e q u e s t   T i m e - o u t ' ,   
     4 0 9 :   ' C o n f l i c t ' ,   
     4 1 0 :   ' G o n e ' ,   
     4 1 1 :   ' L e n g t h   R e q u i r e d ' ,   
     4 1 2 :   ' P r e c o n d i t i o n   F a i l e d ' ,   
     4 1 3 :   ' R e q u e s t   E n t i t y   T o o   L a r g e ' ,   
     4 1 4 :   ' R e q u e s t - U R I   T o o   L a r g e ' ,   
     4 1 5 :   ' U n s u p p o r t e d   M e d i a   T y p e ' ,   
     4 1 6 :   ' R e q u e s t e d   R a n g e   N o t   S a t i s f i a b l e ' ,   
     4 1 7 :   ' E x p e c t a t i o n   F a i l e d ' ,   
     4 1 8 :   ' I \ ' m   a   t e a p o t ' ,                             / /   R F C   2 3 2 4   
     4 2 2 :   ' U n p r o c e s s a b l e   E n t i t y ' ,               / /   R F C   4 9 1 8   
     4 2 3 :   ' L o c k e d ' ,                                           / /   R F C   4 9 1 8   
     4 2 4 :   ' F a i l e d   D e p e n d e n c y ' ,                     / /   R F C   4 9 1 8   
     4 2 5 :   ' U n o r d e r e d   C o l l e c t i o n ' ,               / /   R F C   4 9 1 8   
     4 2 6 :   ' U p g r a d e   R e q u i r e d ' ,                       / /   R F C   2 8 1 7   
     4 2 8 :   ' P r e c o n d i t i o n   R e q u i r e d ' ,             / /   R F C   6 5 8 5   
     4 2 9 :   ' T o o   M a n y   R e q u e s t s ' ,                     / /   R F C   6 5 8 5   
     4 3 1 :   ' R e q u e s t   H e a d e r   F i e l d s   T o o   L a r g e ' ,   / /   R F C   6 5 8 5   
     5 0 0 :   ' I n t e r n a l   S e r v e r   E r r o r ' ,   
     5 0 1 :   ' N o t   I m p l e m e n t e d ' ,   
     5 0 2 :   ' B a d   G a t e w a y ' ,   
     5 0 3 :   ' S e r v i c e   U n a v a i l a b l e ' ,   
     5 0 4 :   ' G a t e w a y   T i m e - o u t ' ,   
     5 0 5 :   ' H T T P   V e r s i o n   N o t   S u p p o r t e d ' ,   
     5 0 6 :   ' V a r i a n t   A l s o   N e g o t i a t e s ' ,         / /   R F C   2 2 9 5   
     5 0 7 :   ' I n s u f f i c i e n t   S t o r a g e ' ,               / /   R F C   4 9 1 8   
     5 0 9 :   ' B a n d w i d t h   L i m i t   E x c e e d e d ' ,   
     5 1 0 :   ' N o t   E x t e n d e d ' ,                               / /   R F C   2 7 7 4   
     5 1 1 :   ' N e t w o r k   A u t h e n t i c a t i o n   R e q u i r e d '   / /   R F C   6 5 8 5   
 }   
 
 } ) ;   H   ��
 N O D E _ M O D U L E S / H T T P S . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / * *   
   *   H T T P S   c l i e n t .   
   *   @ m o d u l e   h t t p s   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
     
 l e t   h t t p   =   r e q u i r e ( ' h t t p ' ) ;   
   
 e x p o r t s . r e q u e s t   =   f u n c t i o n   r e q u e s t ( o p t i o n s )   {   
 	 o p t i o n s . u s e H T T P S   =   t r u e ;   
 	 r e t u r n   h t t p . r e q u e s t ( o p t i o n s ) ;   
 }   
 e x p o r t s . g e t   =   f u n c t i o n   r e q u e s t ( o p t i o n s )   {   
 	 o p t i o n s . u s e H T T P S   =   t r u e ;   
 	 r e t u r n   h t t p . g e t ( o p t i o n s ) ;   
 }   
   
 
 } ) ;   �  \   ��
 N O D E _ M O D U L E S / I N T E R N A L / E R R O R S . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / *   e s l i n t   d o c u m e n t e d - e r r o r s :   " e r r o r "   * / 
 / *   e s l i n t   a l p h a b e t i z e - e r r o r s :   " e r r o r "   * / 
 / *   e s l i n t   p r e f e r - u t i l - f o r m a t - e r r o r s :   " e r r o r "   * / 
 
 ' u s e   s t r i c t ' ; 
 
 / /   T h e   w h o l e   p o i n t   b e h i n d   t h i s   i n t e r n a l   m o d u l e   i s   t o   a l l o w   N o d e . j s   t o   n o 
 / /   l o n g e r   b e   f o r c e d   t o   t r e a t   e v e r y   e r r o r   m e s s a g e   c h a n g e   a s   a   s e m v e r - m a j o r 
 / /   c h a n g e .   T h e   N o d e E r r o r   c l a s s e s   h e r e   a l l   e x p o s e   a   ` c o d e `   p r o p e r t y   w h o s e 
 / /   v a l u e   s t a t i c a l l y   a n d   p e r m a n e n t l y   i d e n t i f i e s   t h e   e r r o r .   W h i l e   t h e   e r r o r 
 / /   m e s s a g e   m a y   c h a n g e ,   t h e   c o d e   s h o u l d   n o t . 
 
 c o n s t   k C o d e   =   S y m b o l ( ' c o d e ' ) ; 
 c o n s t   k I n f o   =   S y m b o l ( ' i n f o ' ) ; 
 c o n s t   m e s s a g e s   =   n e w   M a p ( ) ; 
 
 c o n s t   {   k M a x L e n g t h   }   =   p r o c e s s . b i n d i n g ( ' b u f f e r ' ) ; 
 c o n s t   {   d e f i n e P r o p e r t y   }   =   O b j e c t ; 
 
 / /   L a z i l y   l o a d e d 
 v a r   u t i l   =   n u l l ; 
 v a r   b u f f e r ; 
 
 f u n c t i o n   m a k e N o d e E r r o r ( B a s e )   { 
     r e t u r n   c l a s s   N o d e E r r o r   e x t e n d s   B a s e   { 
         c o n s t r u c t o r ( k e y ,   . . . a r g s )   { 
             s u p e r ( m e s s a g e ( k e y ,   a r g s ) ) ; 
             d e f i n e P r o p e r t y ( t h i s ,   k C o d e ,   { 
                 c o n f i g u r a b l e :   t r u e , 
                 e n u m e r a b l e :   f a l s e , 
                 v a l u e :   k e y , 
                 w r i t a b l e :   t r u e 
             } ) ; 
         } 
 
         g e t   n a m e ( )   { 
             r e t u r n   ` $ { s u p e r . n a m e }   [ $ { t h i s [ k C o d e ] } ] ` ; 
         } 
 
         s e t   n a m e ( v a l u e )   { 
             d e f i n e P r o p e r t y ( t h i s ,   ' n a m e ' ,   { 
                 c o n f i g u r a b l e :   t r u e , 
                 e n u m e r a b l e :   t r u e , 
                 v a l u e , 
                 w r i t a b l e :   t r u e 
             } ) ; 
         } 
 
         g e t   c o d e ( )   { 
             r e t u r n   t h i s [ k C o d e ] ; 
         } 
 
         s e t   c o d e ( v a l u e )   { 
             d e f i n e P r o p e r t y ( t h i s ,   ' c o d e ' ,   { 
                 c o n f i g u r a b l e :   t r u e , 
                 e n u m e r a b l e :   t r u e , 
                 v a l u e , 
                 w r i t a b l e :   t r u e 
             } ) ; 
         } 
     } ; 
 } 
 
 f u n c t i o n   l a z y B u f f e r ( )   { 
     i f   ( b u f f e r   = = =   u n d e f i n e d ) 
         b u f f e r   =   r e q u i r e ( ' b u f f e r ' ) . B u f f e r ; 
     r e t u r n   b u f f e r ; 
 } 
 
 / /   A   s p e c i a l i z e d   E r r o r   t h a t   i n c l u d e s   a n   a d d i t i o n a l   i n f o   p r o p e r t y   w i t h 
 / /   a d d i t i o n a l   i n f o r m a t i o n   a b o u t   t h e   e r r o r   c o n d i t i o n .   T h e   c o d e   k e y   w i l l 
 / /   b e   e x t r a c t e d   f r o m   t h e   c o n t e x t   o b j e c t   o r   t h e   E R R _ S Y S T E M _ E R R O R   d e f a u l t 
 / /   w i l l   b e   u s e d . 
 c l a s s   S y s t e m E r r o r   e x t e n d s   m a k e N o d e E r r o r ( E r r o r )   { 
     c o n s t r u c t o r ( c o n t e x t )   { 
         c o n t e x t   =   c o n t e x t   | |   { } ; 
         l e t   c o d e   =   ' E R R _ S Y S T E M _ E R R O R ' ; 
         i f   ( m e s s a g e s . h a s ( c o n t e x t . c o d e ) ) 
             c o d e   =   c o n t e x t . c o d e ; 
         s u p e r ( c o d e , 
                     c o n t e x t . c o d e , 
                     c o n t e x t . s y s c a l l , 
                     c o n t e x t . p a t h , 
                     c o n t e x t . d e s t , 
                     c o n t e x t . m e s s a g e ) ; 
         O b j e c t . d e f i n e P r o p e r t y ( t h i s ,   k I n f o ,   { 
             c o n f i g u r a b l e :   f a l s e , 
             e n u m e r a b l e :   f a l s e , 
             v a l u e :   c o n t e x t 
         } ) ; 
     } 
 
     g e t   i n f o ( )   { 
         r e t u r n   t h i s [ k I n f o ] ; 
     } 
 
     g e t   e r r n o ( )   { 
         r e t u r n   t h i s [ k I n f o ] . e r r n o ; 
     } 
 
     s e t   e r r n o ( v a l )   { 
         t h i s [ k I n f o ] . e r r n o   =   v a l ; 
     } 
 
     g e t   s y s c a l l ( )   { 
         r e t u r n   t h i s [ k I n f o ] . s y s c a l l ; 
     } 
 
     s e t   s y s c a l l ( v a l )   { 
         t h i s [ k I n f o ] . s y s c a l l   =   v a l ; 
     } 
 
     g e t   p a t h ( )   { 
         r e t u r n   t h i s [ k I n f o ] . p a t h   ! = =   u n d e f i n e d   ? 
             t h i s [ k I n f o ] . p a t h . t o S t r i n g ( )   :   u n d e f i n e d ; 
     } 
 
     s e t   p a t h ( v a l )   { 
         t h i s [ k I n f o ] . p a t h   =   v a l   ? 
             l a z y B u f f e r ( ) . f r o m ( v a l . t o S t r i n g ( ) )   :   u n d e f i n e d ; 
     } 
 
     g e t   d e s t ( )   { 
         r e t u r n   t h i s [ k I n f o ] . p a t h   ! = =   u n d e f i n e d   ? 
             t h i s [ k I n f o ] . d e s t . t o S t r i n g ( )   :   u n d e f i n e d ; 
     } 
 
     s e t   d e s t ( v a l )   { 
         t h i s [ k I n f o ] . d e s t   =   v a l   ? 
             l a z y B u f f e r ( ) . f r o m ( v a l . t o S t r i n g ( ) )   :   u n d e f i n e d ; 
     } 
 } 
 
 c l a s s   A s s e r t i o n E r r o r   e x t e n d s   E r r o r   { 
     c o n s t r u c t o r ( o p t i o n s )   { 
         i f   ( t y p e o f   o p t i o n s   ! = =   ' o b j e c t '   | |   o p t i o n s   = = =   n u l l )   { 
             t h r o w   n e w   e x p o r t s . T y p e E r r o r ( ' E R R _ I N V A L I D _ A R G _ T Y P E ' ,   ' o p t i o n s ' ,   ' O b j e c t ' ) ; 
         } 
         v a r   {   a c t u a l ,   e x p e c t e d ,   m e s s a g e ,   o p e r a t o r ,   s t a c k S t a r t F u n c t i o n   }   =   o p t i o n s ; 
         i f   ( m e s s a g e )   { 
             s u p e r ( m e s s a g e ) ; 
         }   e l s e   { 
             i f   ( a c t u a l   & &   a c t u a l . s t a c k   & &   a c t u a l   i n s t a n c e o f   E r r o r ) 
                 a c t u a l   =   ` $ { a c t u a l . n a m e } :   $ { a c t u a l . m e s s a g e } ` ; 
             i f   ( e x p e c t e d   & &   e x p e c t e d . s t a c k   & &   e x p e c t e d   i n s t a n c e o f   E r r o r ) 
                 e x p e c t e d   =   ` $ { e x p e c t e d . n a m e } :   $ { e x p e c t e d . m e s s a g e } ` ; 
             i f   ( u t i l   = = =   n u l l )   u t i l   =   r e q u i r e ( ' u t i l ' ) ; 
             s u p e r ( ` $ { u t i l . i n s p e c t ( a c t u a l ) . s l i c e ( 0 ,   1 2 8 ) }   `   + 
                 ` $ { o p e r a t o r }   $ { u t i l . i n s p e c t ( e x p e c t e d ) . s l i c e ( 0 ,   1 2 8 ) } ` ) ; 
         } 
 
         t h i s . g e n e r a t e d M e s s a g e   =   ! m e s s a g e ; 
         t h i s . n a m e   =   ' A s s e r t i o n E r r o r   [ E R R _ A S S E R T I O N ] ' ; 
         t h i s . c o d e   =   ' E R R _ A S S E R T I O N ' ; 
         t h i s . a c t u a l   =   a c t u a l ; 
         t h i s . e x p e c t e d   =   e x p e c t e d ; 
         t h i s . o p e r a t o r   =   o p e r a t o r ; 
         E r r o r . c a p t u r e S t a c k T r a c e ( t h i s ,   s t a c k S t a r t F u n c t i o n ) ; 
     } 
 } 
 
 / /   T h i s   i s   d e f i n e d   h e r e   i n s t e a d   o f   u s i n g   t h e   a s s e r t   m o d u l e   t o   a v o i d   a 
 / /   c i r c u l a r   d e p e n d e n c y .   T h e   e f f e c t   i s   l a r g e l y   t h e   s a m e . 
 f u n c t i o n   i n t e r n a l A s s e r t ( c o n d i t i o n ,   m e s s a g e )   { 
     i f   ( ! c o n d i t i o n )   { 
         t h r o w   n e w   A s s e r t i o n E r r o r ( { 
             m e s s a g e , 
             a c t u a l :   f a l s e , 
             e x p e c t e d :   t r u e , 
             o p e r a t o r :   ' = = ' 
         } ) ; 
     } 
 } 
 
 f u n c t i o n   m e s s a g e ( k e y ,   a r g s )   { 
     c o n s t   m s g   =   m e s s a g e s . g e t ( k e y ) ; 
     i n t e r n a l A s s e r t ( m s g ,   ` A n   i n v a l i d   e r r o r   m e s s a g e   k e y   w a s   u s e d :   $ { k e y } . ` ) ; 
     l e t   f m t ; 
     i f   ( t y p e o f   m s g   = = =   ' f u n c t i o n ' )   { 
         f m t   =   m s g ; 
     }   e l s e   { 
         i f   ( u t i l   = = =   n u l l )   u t i l   =   r e q u i r e ( ' u t i l ' ) ; 
         f m t   =   u t i l . f o r m a t ; 
         i f   ( a r g s   = = =   u n d e f i n e d   | |   a r g s . l e n g t h   = = =   0 ) 
             r e t u r n   m s g ; 
         a r g s . u n s h i f t ( m s g ) ; 
     } 
     r e t u r n   S t r i n g ( f m t . a p p l y ( n u l l ,   a r g s ) ) ; 
 } 
 
 / /   U t i l i t y   f u n c t i o n   f o r   r e g i s t e r i n g   t h e   e r r o r   c o d e s .   O n l y   u s e d   h e r e .   E x p o r t e d 
 / /   * o n l y *   t o   a l l o w   f o r   t e s t i n g . 
 f u n c t i o n   E ( s y m ,   v a l )   { 
     m e s s a g e s . s e t ( s y m ,   t y p e o f   v a l   = = =   ' f u n c t i o n '   ?   v a l   :   S t r i n g ( v a l ) ) ; 
 } 
 
 m o d u l e . e x p o r t s   =   e x p o r t s   =   { 
     m e s s a g e , 
     E r r o r :   m a k e N o d e E r r o r ( E r r o r ) , 
     T y p e E r r o r :   m a k e N o d e E r r o r ( T y p e E r r o r ) , 
     R a n g e E r r o r :   m a k e N o d e E r r o r ( R a n g e E r r o r ) , 
     U R I E r r o r :   m a k e N o d e E r r o r ( U R I E r r o r ) , 
     A s s e r t i o n E r r o r , 
     S y s t e m E r r o r , 
     E   / /   T h i s   i s   e x p o r t e d   o n l y   t o   f a c i l i t a t e   t e s t i n g . 
 } ; 
 
 / /   T o   d e c l a r e   a n   e r r o r   m e s s a g e ,   u s e   t h e   E ( s y m ,   v a l )   f u n c t i o n   a b o v e .   T h e   s y m 
 / /   m u s t   b e   a n   u p p e r   c a s e   s t r i n g .   T h e   v a l   c a n   b e   e i t h e r   a   f u n c t i o n   o r   a   s t r i n g . 
 / /   T h e   r e t u r n   v a l u e   o f   t h e   f u n c t i o n   m u s t   b e   a   s t r i n g . 
 / /   E x a m p l e s : 
 / /   E ( ' E X A M P L E _ K E Y 1 ' ,   ' T h i s   i s   t h e   e r r o r   v a l u e ' ) ; 
 / /   E ( ' E X A M P L E _ K E Y 2 ' ,   ( a ,   b )   = >   r e t u r n   ` $ { a }   $ { b } ` ) ; 
 / / 
 / /   O n c e   a n   e r r o r   c o d e   h a s   b e e n   a s s i g n e d ,   t h e   c o d e   i t s e l f   M U S T   N O T   c h a n g e   a n d 
 / /   a n y   g i v e n   e r r o r   c o d e   m u s t   n e v e r   b e   r e u s e d   t o   i d e n t i f y   a   d i f f e r e n t   e r r o r . 
 / / 
 / /   A n y   e r r o r   c o d e   a d d e d   h e r e   s h o u l d   a l s o   b e   a d d e d   t o   t h e   d o c u m e n t a t i o n 
 / / 
 / /   N o t e :   P l e a s e   t r y   t o   k e e p   t h e s e   i n   a l p h a b e t i c a l   o r d e r 
 / / 
 / /   N o t e :   N o d e . j s   s p e c i f i c   e r r o r s   m u s t   b e g i n   w i t h   t h e   p r e f i x   E R R _ 
 
 E ( ' E R R _ A R G _ N O T _ I T E R A B L E ' ,   ' % s   m u s t   b e   i t e r a b l e ' ) ; 
 E ( ' E R R _ A S S E R T I O N ' ,   ' % s ' ) ; 
 E ( ' E R R _ A S Y N C _ C A L L B A C K ' ,   ' % s   m u s t   b e   a   f u n c t i o n ' ) ; 
 E ( ' E R R _ A S Y N C _ T Y P E ' ,   ' I n v a l i d   n a m e   f o r   a s y n c   " t y p e " :   % s ' ) ; 
 E ( ' E R R _ B U F F E R _ O U T _ O F _ B O U N D S ' ,   b u f f e r O u t O f B o u n d s ) ; 
 E ( ' E R R _ B U F F E R _ T O O _ L A R G E ' , 
     ` C a n n o t   c r e a t e   a   B u f f e r   l a r g e r   t h a n   0 x $ { k M a x L e n g t h . t o S t r i n g ( 1 6 ) }   b y t e s ` ) ; 
 E ( ' E R R _ C A N N O T _ W A T C H _ S I G I N T ' ,   ' C a n n o t   w a t c h   f o r   S I G I N T   s i g n a l s ' ) ; 
 E ( ' E R R _ C H I L D _ C L O S E D _ B E F O R E _ R E P L Y ' ,   ' C h i l d   c l o s e d   b e f o r e   r e p l y   r e c e i v e d ' ) ; 
 E ( ' E R R _ C O N S O L E _ W R I T A B L E _ S T R E A M ' , 
     ' C o n s o l e   e x p e c t s   a   w r i t a b l e   s t r e a m   i n s t a n c e   f o r   % s ' ) ; 
 E ( ' E R R _ C P U _ U S A G E ' ,   ' U n a b l e   t o   o b t a i n   c p u   u s a g e   % s ' ) ; 
 E ( ' E R R _ C R Y P T O _ C U S T O M _ E N G I N E _ N O T _ S U P P O R T E D ' , 
     ' C u s t o m   e n g i n e s   n o t   s u p p o r t e d   b y   t h i s   O p e n S S L ' ) ; 
 E ( ' E R R _ C R Y P T O _ E C D H _ I N V A L I D _ F O R M A T ' ,   ' I n v a l i d   E C D H   f o r m a t :   % s ' ) ; 
 E ( ' E R R _ C R Y P T O _ E N G I N E _ U N K N O W N ' ,   ' E n g i n e   " % s "   w a s   n o t   f o u n d ' ) ; 
 E ( ' E R R _ C R Y P T O _ F I P S _ F O R C E D ' , 
     ' C a n n o t   s e t   F I P S   m o d e ,   i t   w a s   f o r c e d   w i t h   - - f o r c e - f i p s   a t   s t a r t u p . ' ) ; 
 E ( ' E R R _ C R Y P T O _ F I P S _ U N A V A I L A B L E ' ,   ' C a n n o t   s e t   F I P S   m o d e   i n   a   n o n - F I P S   b u i l d . ' ) ; 
 E ( ' E R R _ C R Y P T O _ H A S H _ D I G E S T _ N O _ U T F 1 6 ' ,   ' h a s h . d i g e s t ( )   d o e s   n o t   s u p p o r t   U T F - 1 6 ' ) ; 
 E ( ' E R R _ C R Y P T O _ H A S H _ F I N A L I Z E D ' ,   ' D i g e s t   a l r e a d y   c a l l e d ' ) ; 
 E ( ' E R R _ C R Y P T O _ H A S H _ U P D A T E _ F A I L E D ' ,   ' H a s h   u p d a t e   f a i l e d ' ) ; 
 E ( ' E R R _ C R Y P T O _ I N V A L I D _ D I G E S T ' ,   ' I n v a l i d   d i g e s t :   % s ' ) ; 
 E ( ' E R R _ C R Y P T O _ I N V A L I D _ S T A T E ' ,   ' I n v a l i d   s t a t e   f o r   o p e r a t i o n   % s ' ) ; 
 E ( ' E R R _ C R Y P T O _ S I G N _ K E Y _ R E Q U I R E D ' ,   ' N o   k e y   p r o v i d e d   t o   s i g n ' ) ; 
 E ( ' E R R _ C R Y P T O _ T I M I N G _ S A F E _ E Q U A L _ L E N G T H ' , 
     ' I n p u t   b u f f e r s   m u s t   h a v e   t h e   s a m e   l e n g t h ' ) ; 
 E ( ' E R R _ D N S _ S E T _ S E R V E R S _ F A I L E D ' ,   ' c - a r e s   f a i l e d   t o   s e t   s e r v e r s :   " % s "   [ % s ] ' ) ; 
 E ( ' E R R _ E N C O D I N G _ I N V A L I D _ E N C O D E D _ D A T A ' , 
     ' T h e   e n c o d e d   d a t a   w a s   n o t   v a l i d   f o r   e n c o d i n g   % s ' ) ; 
 E ( ' E R R _ E N C O D I N G _ N O T _ S U P P O R T E D ' ,   ' T h e   " % s "   e n c o d i n g   i s   n o t   s u p p o r t e d ' ) ; 
 E ( ' E R R _ F A L S Y _ V A L U E _ R E J E C T I O N ' ,   ' P r o m i s e   w a s   r e j e c t e d   w i t h   f a l s y   v a l u e ' ) ; 
 E ( ' E R R _ H T T P 2 _ C O N N E C T _ A U T H O R I T Y ' , 
     ' : a u t h o r i t y   h e a d e r   i s   r e q u i r e d   f o r   C O N N E C T   r e q u e s t s ' ) ; 
 E ( ' E R R _ H T T P 2 _ C O N N E C T _ P A T H ' , 
     ' T h e   : p a t h   h e a d e r   i s   f o r b i d d e n   f o r   C O N N E C T   r e q u e s t s ' ) ; 
 E ( ' E R R _ H T T P 2 _ C O N N E C T _ S C H E M E ' , 
     ' T h e   : s c h e m e   h e a d e r   i s   f o r b i d d e n   f o r   C O N N E C T   r e q u e s t s ' ) ; 
 E ( ' E R R _ H T T P 2 _ F R A M E _ E R R O R ' , 
     ( t y p e ,   c o d e ,   i d )   = >   { 
         l e t   m s g   =   ` E r r o r   s e n d i n g   f r a m e   t y p e   $ { t y p e } ` ; 
         i f   ( i d   ! = =   u n d e f i n e d ) 
             m s g   + =   `   f o r   s t r e a m   $ { i d } ` ; 
         m s g   + =   `   w i t h   c o d e   $ { c o d e } ` ; 
         r e t u r n   m s g ; 
     } ) ; 
 E ( ' E R R _ H T T P 2 _ H E A D E R S _ A F T E R _ R E S P O N D ' , 
     ' C a n n o t   s p e c i f y   a d d i t i o n a l   h e a d e r s   a f t e r   r e s p o n s e   i n i t i a t e d ' ) ; 
 E ( ' E R R _ H T T P 2 _ H E A D E R S _ O B J E C T ' ,   ' H e a d e r s   m u s t   b e   a n   o b j e c t ' ) ; 
 E ( ' E R R _ H T T P 2 _ H E A D E R S _ S E N T ' ,   ' R e s p o n s e   h a s   a l r e a d y   b e e n   i n i t i a t e d . ' ) ; 
 E ( ' E R R _ H T T P 2 _ H E A D E R _ R E Q U I R E D ' ,   ' T h e   % s   h e a d e r   i s   r e q u i r e d ' ) ; 
 E ( ' E R R _ H T T P 2 _ H E A D E R _ S I N G L E _ V A L U E ' , 
     ' H e a d e r   f i e l d   " % s "   m u s t   h a v e   o n l y   a   s i n g l e   v a l u e ' ) ; 
 E ( ' E R R _ H T T P 2 _ I N F O _ H E A D E R S _ A F T E R _ R E S P O N D ' , 
     ' C a n n o t   s e n d   i n f o r m a t i o n a l   h e a d e r s   a f t e r   t h e   H T T P   m e s s a g e   h a s   b e e n   s e n t ' ) ; 
 E ( ' E R R _ H T T P 2 _ I N F O _ S T A T U S _ N O T _ A L L O W E D ' , 
     ' I n f o r m a t i o n a l   s t a t u s   c o d e s   c a n n o t   b e   u s e d ' ) ; 
 E ( ' E R R _ H T T P 2 _ I N V A L I D _ C O N N E C T I O N _ H E A D E R S ' , 
     ' H T T P / 1   C o n n e c t i o n   s p e c i f i c   h e a d e r s   a r e   f o r b i d d e n :   " % s " ' ) ; 
 E ( ' E R R _ H T T P 2 _ I N V A L I D _ H E A D E R _ V A L U E ' ,   ' I n v a l i d   v a l u e   " % s "   f o r   h e a d e r   " % s " ' ) ; 
 E ( ' E R R _ H T T P 2 _ I N V A L I D _ I N F O _ S T A T U S ' , 
     ' I n v a l i d   i n f o r m a t i o n a l   s t a t u s   c o d e :   % s ' ) ; 
 E ( ' E R R _ H T T P 2 _ I N V A L I D _ P A C K E D _ S E T T I N G S _ L E N G T H ' , 
     ' P a c k e d   s e t t i n g s   l e n g t h   m u s t   b e   a   m u l t i p l e   o f   s i x ' ) ; 
 E ( ' E R R _ H T T P 2 _ I N V A L I D _ P S E U D O H E A D E R ' , 
     ' " % s "   i s   a n   i n v a l i d   p s e u d o h e a d e r   o r   i s   u s e d   i n c o r r e c t l y ' ) ; 
 E ( ' E R R _ H T T P 2 _ I N V A L I D _ S E S S I O N ' ,   ' T h e   s e s s i o n   h a s   b e e n   d e s t r o y e d ' ) ; 
 E ( ' E R R _ H T T P 2 _ I N V A L I D _ S E T T I N G _ V A L U E ' , 
     ' I n v a l i d   v a l u e   f o r   s e t t i n g   " % s " :   % s ' ) ; 
 E ( ' E R R _ H T T P 2 _ I N V A L I D _ S T R E A M ' ,   ' T h e   s t r e a m   h a s   b e e n   d e s t r o y e d ' ) ; 
 E ( ' E R R _ H T T P 2 _ M A X _ P E N D I N G _ S E T T I N G S _ A C K ' , 
     ' M a x i m u m   n u m b e r   o f   p e n d i n g   s e t t i n g s   a c k n o w l e d g e m e n t s   ( % s ) ' ) ; 
 E ( ' E R R _ H T T P 2 _ N O _ S O C K E T _ M A N I P U L A T I O N ' , 
     ' H T T P / 2   s o c k e t s   s h o u l d   n o t   b e   d i r e c t l y   m a n i p u l a t e d   ( e . g .   r e a d   a n d   w r i t t e n ) ' ) ; 
 E ( ' E R R _ H T T P 2 _ O U T _ O F _ S T R E A M S ' , 
     ' N o   s t r e a m   I D   i s   a v a i l a b l e   b e c a u s e   m a x i m u m   s t r e a m   I D   h a s   b e e n   r e a c h e d ' ) ; 
 E ( ' E R R _ H T T P 2 _ P A Y L O A D _ F O R B I D D E N ' , 
     ' R e s p o n s e s   w i t h   % s   s t a t u s   m u s t   n o t   h a v e   a   p a y l o a d ' ) ; 
 E ( ' E R R _ H T T P 2 _ P S E U D O H E A D E R _ N O T _ A L L O W E D ' ,   ' C a n n o t   s e t   H T T P / 2   p s e u d o - h e a d e r s ' ) ; 
 E ( ' E R R _ H T T P 2 _ P U S H _ D I S A B L E D ' ,   ' H T T P / 2   c l i e n t   h a s   d i s a b l e d   p u s h   s t r e a m s ' ) ; 
 E ( ' E R R _ H T T P 2 _ S E N D _ F I L E ' ,   ' O n l y   r e g u l a r   f i l e s   c a n   b e   s e n t ' ) ; 
 E ( ' E R R _ H T T P 2 _ S O C K E T _ B O U N D ' , 
     ' T h e   s o c k e t   i s   a l r e a d y   b o u n d   t o   a n   H t t p 2 S e s s i o n ' ) ; 
 E ( ' E R R _ H T T P 2 _ S T A T U S _ 1 0 1 ' , 
     ' H T T P   s t a t u s   c o d e   1 0 1   ( S w i t c h i n g   P r o t o c o l s )   i s   f o r b i d d e n   i n   H T T P / 2 ' ) ; 
 E ( ' E R R _ H T T P 2 _ S T A T U S _ I N V A L I D ' ,   ' I n v a l i d   s t a t u s   c o d e :   % s ' ) ; 
 E ( ' E R R _ H T T P 2 _ S T R E A M _ C L O S E D ' ,   ' T h e   s t r e a m   i s   a l r e a d y   c l o s e d ' ) ; 
 E ( ' E R R _ H T T P 2 _ S T R E A M _ E R R O R ' ,   ' S t r e a m   c l o s e d   w i t h   e r r o r   c o d e   % s ' ) ; 
 E ( ' E R R _ H T T P 2 _ S T R E A M _ S E L F _ D E P E N D E N C Y ' ,   ' A   s t r e a m   c a n n o t   d e p e n d   o n   i t s e l f ' ) ; 
 E ( ' E R R _ H T T P 2 _ U N S U P P O R T E D _ P R O T O C O L ' ,   ' p r o t o c o l   " % s "   i s   u n s u p p o r t e d . ' ) ; 
 E ( ' E R R _ H T T P _ H E A D E R S _ S E N T ' , 
     ' C a n n o t   % s   h e a d e r s   a f t e r   t h e y   a r e   s e n t   t o   t h e   c l i e n t ' ) ; 
 E ( ' E R R _ H T T P _ I N V A L I D _ C H A R ' ,   ' I n v a l i d   c h a r a c t e r   i n   s t a t u s M e s s a g e . ' ) ; 
 E ( ' E R R _ H T T P _ I N V A L I D _ H E A D E R _ V A L U E ' ,   ' I n v a l i d   v a l u e   " % s "   f o r   h e a d e r   " % s " ' ) ; 
 E ( ' E R R _ H T T P _ I N V A L I D _ S T A T U S _ C O D E ' ,   ' I n v a l i d   s t a t u s   c o d e :   % s ' ) ; 
 E ( ' E R R _ H T T P _ T R A I L E R _ I N V A L I D ' , 
     ' T r a i l e r s   a r e   i n v a l i d   w i t h   t h i s   t r a n s f e r   e n c o d i n g ' ) ; 
 E ( ' E R R _ I N D E X _ O U T _ O F _ R A N G E ' ,   ' I n d e x   o u t   o f   r a n g e ' ) ; 
 E ( ' E R R _ I N S P E C T O R _ A L R E A D Y _ C O N N E C T E D ' ,   ' T h e   i n s p e c t o r   i s   a l r e a d y   c o n n e c t e d ' ) ; 
 E ( ' E R R _ I N S P E C T O R _ C L O S E D ' ,   ' S e s s i o n   w a s   c l o s e d ' ) ; 
 E ( ' E R R _ I N S P E C T O R _ N O T _ A V A I L A B L E ' ,   ' I n s p e c t o r   i s   n o t   a v a i l a b l e ' ) ; 
 E ( ' E R R _ I N S P E C T O R _ N O T _ C O N N E C T E D ' ,   ' S e s s i o n   i s   n o t   c o n n e c t e d ' ) ; 
 E ( ' E R R _ I N V A L I D _ A R G _ T Y P E ' ,   i n v a l i d A r g T y p e ) ; 
 E ( ' E R R _ I N V A L I D _ A R G _ V A L U E ' ,   ( n a m e ,   v a l u e )   = > 
     ` T h e   v a l u e   " $ { S t r i n g ( v a l u e ) } "   i s   i n v a l i d   f o r   a r g u m e n t   " $ { n a m e } " ` ) ; 
 E ( ' E R R _ I N V A L I D _ A R R A Y _ L E N G T H ' , 
     ( n a m e ,   l e n ,   a c t u a l )   = >   { 
         i n t e r n a l A s s e r t ( t y p e o f   a c t u a l   = = =   ' n u m b e r ' ,   ' a c t u a l   m u s t   b e   a   n u m b e r ' ) ; 
         r e t u r n   ` T h e   a r r a y   " $ { n a m e } "   ( l e n g t h   $ { a c t u a l } )   m u s t   b e   o f   l e n g t h   $ { l e n } . ` ; 
     } ) ; 
 E ( ' E R R _ I N V A L I D _ A S Y N C _ I D ' ,   ' I n v a l i d   % s   v a l u e :   % s ' ) ; 
 E ( ' E R R _ I N V A L I D _ B U F F E R _ S I Z E ' ,   ' B u f f e r   s i z e   m u s t   b e   a   m u l t i p l e   o f   % s ' ) ; 
 E ( ' E R R _ I N V A L I D _ C A L L B A C K ' ,   ' C a l l b a c k   m u s t   b e   a   f u n c t i o n ' ) ; 
 E ( ' E R R _ I N V A L I D _ C H A R ' ,   i n v a l i d C h a r ) ; 
 E ( ' E R R _ I N V A L I D _ C U R S O R _ P O S ' , 
     ' C a n n o t   s e t   c u r s o r   r o w   w i t h o u t   s e t t i n g   i t s   c o l u m n ' ) ; 
 E ( ' E R R _ I N V A L I D _ D O M A I N _ N A M E ' ,   ' U n a b l e   t o   d e t e r m i n e   t h e   d o m a i n   n a m e ' ) ; 
 E ( ' E R R _ I N V A L I D _ F D ' ,   ' " f d "   m u s t   b e   a   p o s i t i v e   i n t e g e r :   % s ' ) ; 
 E ( ' E R R _ I N V A L I D _ F D _ T Y P E ' ,   ' U n s u p p o r t e d   f d   t y p e :   % s ' ) ; 
 E ( ' E R R _ I N V A L I D _ F I L E _ U R L _ H O S T ' , 
     ' F i l e   U R L   h o s t   m u s t   b e   " l o c a l h o s t "   o r   e m p t y   o n   % s ' ) ; 
 E ( ' E R R _ I N V A L I D _ F I L E _ U R L _ P A T H ' ,   ' F i l e   U R L   p a t h   % s ' ) ; 
 E ( ' E R R _ I N V A L I D _ H A N D L E _ T Y P E ' ,   ' T h i s   h a n d l e   t y p e   c a n n o t   b e   s e n t ' ) ; 
 E ( ' E R R _ I N V A L I D _ H T T P _ T O K E N ' ,   ' % s   m u s t   b e   a   v a l i d   H T T P   t o k e n   [ " % s " ] ' ) ; 
 E ( ' E R R _ I N V A L I D _ I P _ A D D R E S S ' ,   ' I n v a l i d   I P   a d d r e s s :   % s ' ) ; 
 E ( ' E R R _ I N V A L I D _ O P T _ V A L U E ' ,   ( n a m e ,   v a l u e )   = > 
     ` T h e   v a l u e   " $ { S t r i n g ( v a l u e ) } "   i s   i n v a l i d   f o r   o p t i o n   " $ { n a m e } " ` ) ; 
 E ( ' E R R _ I N V A L I D _ O P T _ V A L U E _ E N C O D I N G ' , 
     ' T h e   v a l u e   " % s "   i s   i n v a l i d   f o r   o p t i o n   " e n c o d i n g " ' ) ; 
 E ( ' E R R _ I N V A L I D _ P E R F O R M A N C E _ M A R K ' ,   ' T h e   " % s "   p e r f o r m a n c e   m a r k   h a s   n o t   b e e n   s e t ' ) ; 
 E ( ' E R R _ I N V A L I D _ P R O T O C O L ' ,   ' P r o t o c o l   " % s "   n o t   s u p p o r t e d .   E x p e c t e d   " % s " ' ) ; 
 E ( ' E R R _ I N V A L I D _ R E P L _ E V A L _ C O N F I G ' , 
     ' C a n n o t   s p e c i f y   b o t h   " b r e a k E v a l O n S i g i n t "   a n d   " e v a l "   f o r   R E P L ' ) ; 
 E ( ' E R R _ I N V A L I D _ S Y N C _ F O R K _ I N P U T ' , 
     ' A s y n c h r o n o u s   f o r k s   d o   n o t   s u p p o r t   B u f f e r ,   U i n t 8 A r r a y   o r   s t r i n g   i n p u t :   % s ' ) ; 
 E ( ' E R R _ I N V A L I D _ T H I S ' ,   ' V a l u e   o f   " t h i s "   m u s t   b e   o f   t y p e   % s ' ) ; 
 E ( ' E R R _ I N V A L I D _ T U P L E ' ,   ' % s   m u s t   b e   a n   i t e r a b l e   % s   t u p l e ' ) ; 
 E ( ' E R R _ I N V A L I D _ U R I ' ,   ' U R I   m a l f o r m e d ' ) ; 
 E ( ' E R R _ I N V A L I D _ U R L ' ,   ' I n v a l i d   U R L :   % s ' ) ; 
 E ( ' E R R _ I N V A L I D _ U R L _ S C H E M E ' , 
     ( e x p e c t e d )   = >   ` T h e   U R L   m u s t   b e   $ { o n e O f ( e x p e c t e d ,   ' s c h e m e ' ) } ` ) ; 
 E ( ' E R R _ I P C _ C H A N N E L _ C L O S E D ' ,   ' C h a n n e l   c l o s e d ' ) ; 
 E ( ' E R R _ I P C _ D I S C O N N E C T E D ' ,   ' I P C   c h a n n e l   i s   a l r e a d y   d i s c o n n e c t e d ' ) ; 
 E ( ' E R R _ I P C _ O N E _ P I P E ' ,   ' C h i l d   p r o c e s s   c a n   h a v e   o n l y   o n e   I P C   p i p e ' ) ; 
 E ( ' E R R _ I P C _ S Y N C _ F O R K ' ,   ' I P C   c a n n o t   b e   u s e d   w i t h   s y n c h r o n o u s   f o r k s ' ) ; 
 E ( ' E R R _ M E T H O D _ N O T _ I M P L E M E N T E D ' ,   ' T h e   % s   m e t h o d   i s   n o t   i m p l e m e n t e d ' ) ; 
 E ( ' E R R _ M I S S I N G _ A R G S ' ,   m i s s i n g A r g s ) ; 
 E ( ' E R R _ M I S S I N G _ D Y N A M I C _ I N S T A N T I A T E _ H O O K ' , 
     ' T h e   E S   M o d u l e   l o a d e r   m a y   n o t   r e t u r n   a   f o r m a t   o f   \ ' d y n a m i c \ '   w h e n   n o   '   + 
     ' d y n a m i c I n s t a n t i a t e   f u n c t i o n   w a s   p r o v i d e d ' ) ; 
 E ( ' E R R _ M I S S I N G _ M O D U L E ' ,   ' C a n n o t   f i n d   m o d u l e   % s ' ) ; 
 E ( ' E R R _ M O D U L E _ R E S O L U T I O N _ L E G A C Y ' ,   ' % s   n o t   f o u n d   b y   i m p o r t   i n   % s . '   + 
     '   L e g a c y   b e h a v i o r   i n   r e q u i r e ( )   w o u l d   h a v e   f o u n d   i t   a t   % s ' ) ; 
 E ( ' E R R _ M U L T I P L E _ C A L L B A C K ' ,   ' C a l l b a c k   c a l l e d   m u l t i p l e   t i m e s ' ) ; 
 E ( ' E R R _ N A P I _ C O N S _ F U N C T I O N ' ,   ' C o n s t r u c t o r   m u s t   b e   a   f u n c t i o n ' ) ; 
 E ( ' E R R _ N A P I _ C O N S _ P R O T O T Y P E _ O B J E C T ' ,   ' C o n s t r u c t o r . p r o t o t y p e   m u s t   b e   a n   o b j e c t ' ) ; 
 E ( ' E R R _ N O _ C R Y P T O ' ,   ' N o d e . j s   i s   n o t   c o m p i l e d   w i t h   O p e n S S L   c r y p t o   s u p p o r t ' ) ; 
 E ( ' E R R _ N O _ I C U ' ,   ' % s   i s   n o t   s u p p o r t e d   o n   N o d e . j s   c o m p i l e d   w i t h o u t   I C U ' ) ; 
 E ( ' E R R _ N O _ L O N G E R _ S U P P O R T E D ' ,   ' % s   i s   n o   l o n g e r   s u p p o r t e d ' ) ; 
 E ( ' E R R _ O U T O F M E M O R Y ' ,   ' O u t   o f   m e m o r y ' ) ; 
 E ( ' E R R _ O U T _ O F _ R A N G E ' ,   ' T h e   " % s "   a r g u m e n t   i s   o u t   o f   r a n g e ' ) ; 
 E ( ' E R R _ P A R S E _ H I S T O R Y _ D A T A ' ,   ' C o u l d   n o t   p a r s e   h i s t o r y   d a t a   i n   % s ' ) ; 
 E ( ' E R R _ R E Q U I R E _ E S M ' ,   ' M u s t   u s e   i m p o r t   t o   l o a d   E S   M o d u l e :   % s ' ) ; 
 E ( ' E R R _ S E R V E R _ A L R E A D Y _ L I S T E N ' , 
     ' L i s t e n   m e t h o d   h a s   b e e n   c a l l e d   m o r e   t h a n   o n c e   w i t h o u t   c l o s i n g . ' ) ; 
 E ( ' E R R _ S O C K E T _ A L R E A D Y _ B O U N D ' ,   ' S o c k e t   i s   a l r e a d y   b o u n d ' ) ; 
 E ( ' E R R _ S O C K E T _ B A D _ B U F F E R _ S I Z E ' ,   ' B u f f e r   s i z e   m u s t   b e   a   p o s i t i v e   i n t e g e r ' ) ; 
 E ( ' E R R _ S O C K E T _ B A D _ P O R T ' ,   ' P o r t   s h o u l d   b e   >   0   a n d   <   6 5 5 3 6 .   R e c e i v e d   % s . ' ) ; 
 E ( ' E R R _ S O C K E T _ B A D _ T Y P E ' , 
     ' B a d   s o c k e t   t y p e   s p e c i f i e d .   V a l i d   t y p e s   a r e :   u d p 4 ,   u d p 6 ' ) ; 
 E ( ' E R R _ S O C K E T _ B U F F E R _ S I Z E ' ,   ' C o u l d   n o t   g e t   o r   s e t   b u f f e r   s i z e :   % s ' ) ; 
 E ( ' E R R _ S O C K E T _ C A N N O T _ S E N D ' ,   ' U n a b l e   t o   s e n d   d a t a ' ) ; 
 E ( ' E R R _ S O C K E T _ C L O S E D ' ,   ' S o c k e t   i s   c l o s e d ' ) ; 
 E ( ' E R R _ S O C K E T _ D G R A M _ N O T _ R U N N I N G ' ,   ' N o t   r u n n i n g ' ) ; 
 E ( ' E R R _ S T D E R R _ C L O S E ' ,   ' p r o c e s s . s t d e r r   c a n n o t   b e   c l o s e d ' ) ; 
 E ( ' E R R _ S T D O U T _ C L O S E ' ,   ' p r o c e s s . s t d o u t   c a n n o t   b e   c l o s e d ' ) ; 
 E ( ' E R R _ S T R E A M _ C A N N O T _ P I P E ' ,   ' C a n n o t   p i p e ,   n o t   r e a d a b l e ' ) ; 
 E ( ' E R R _ S T R E A M _ N U L L _ V A L U E S ' ,   ' M a y   n o t   w r i t e   n u l l   v a l u e s   t o   s t r e a m ' ) ; 
 E ( ' E R R _ S T R E A M _ P U S H _ A F T E R _ E O F ' ,   ' s t r e a m . p u s h ( )   a f t e r   E O F ' ) ; 
 E ( ' E R R _ S T R E A M _ R E A D _ N O T _ I M P L E M E N T E D ' ,   ' _ r e a d ( )   i s   n o t   i m p l e m e n t e d ' ) ; 
 E ( ' E R R _ S T R E A M _ U N S H I F T _ A F T E R _ E N D _ E V E N T ' ,   ' s t r e a m . u n s h i f t ( )   a f t e r   e n d   e v e n t ' ) ; 
 E ( ' E R R _ S T R E A M _ W R A P ' ,   ' S t r e a m   h a s   S t r i n g D e c o d e r   s e t   o r   i s   i n   o b j e c t M o d e ' ) ; 
 E ( ' E R R _ S T R E A M _ W R I T E _ A F T E R _ E N D ' ,   ' w r i t e   a f t e r   e n d ' ) ; 
 E ( ' E R R _ S Y S T E M _ E R R O R ' ,   s y s E r r o r ( ' A   s y s t e m   e r r o r   o c c u r r e d ' ) ) ; 
 E ( ' E R R _ T L S _ C E R T _ A L T N A M E _ I N V A L I D ' , 
     ' H o s t n a m e / I P   d o e s   n o t   m a t c h   c e r t i f i c a t e \ ' s   a l t n a m e s :   % s ' ) ; 
 E ( ' E R R _ T L S _ D H _ P A R A M _ S I Z E ' ,   ' D H   p a r a m e t e r   s i z e   % s   i s   l e s s   t h a n   2 0 4 8 ' ) ; 
 E ( ' E R R _ T L S _ H A N D S H A K E _ T I M E O U T ' ,   ' T L S   h a n d s h a k e   t i m e o u t ' ) ; 
 E ( ' E R R _ T L S _ R E N E G O T I A T I O N _ F A I L E D ' ,   ' F a i l e d   t o   r e n e g o t i a t e ' ) ; 
 E ( ' E R R _ T L S _ R E Q U I R E D _ S E R V E R _ N A M E ' , 
     ' " s e r v e r n a m e "   i s   r e q u i r e d   p a r a m e t e r   f o r   S e r v e r . a d d C o n t e x t ' ) ; 
 E ( ' E R R _ T L S _ S E S S I O N _ A T T A C K ' ,   ' T S L   s e s s i o n   r e n e g o t i a t i o n   a t t a c k   d e t e c t e d ' ) ; 
 E ( ' E R R _ T R A N S F O R M _ A L R E A D Y _ T R A N S F O R M I N G ' , 
     ' C a l l i n g   t r a n s f o r m   d o n e   w h e n   s t i l l   t r a n s f o r m i n g ' ) ; 
 E ( ' E R R _ T R A N S F O R M _ W I T H _ L E N G T H _ 0 ' , 
     ' C a l l i n g   t r a n s f o r m   d o n e   w h e n   w r i t a b l e S t a t e . l e n g t h   ! =   0 ' ) ; 
 E ( ' E R R _ U N E S C A P E D _ C H A R A C T E R S ' ,   ' % s   c o n t a i n s   u n e s c a p e d   c h a r a c t e r s ' ) ; 
 E ( ' E R R _ U N H A N D L E D _ E R R O R ' , 
     ( e r r )   = >   { 
         c o n s t   m s g   =   ' U n h a n d l e d   e r r o r . ' ; 
         i f   ( e r r   = = =   u n d e f i n e d )   r e t u r n   m s g ; 
         r e t u r n   ` $ { m s g }   ( $ { e r r } ) ` ; 
     } ) ; 
 E ( ' E R R _ U N K N O W N _ E N C O D I N G ' ,   ' U n k n o w n   e n c o d i n g :   % s ' ) ; 
 E ( ' E R R _ U N K N O W N _ F I L E _ E X T E N S I O N ' ,   ' U n k n o w n   f i l e   e x t e n s i o n :   % s ' ) ; 
 E ( ' E R R _ U N K N O W N _ M O D U L E _ F O R M A T ' ,   ' U n k n o w n   m o d u l e   f o r m a t :   % s ' ) ; 
 E ( ' E R R _ U N K N O W N _ S I G N A L ' ,   ' U n k n o w n   s i g n a l :   % s ' ) ; 
 E ( ' E R R _ U N K N O W N _ S T D I N _ T Y P E ' ,   ' U n k n o w n   s t d i n   f i l e   t y p e ' ) ; 
 E ( ' E R R _ U N K N O W N _ S T R E A M _ T Y P E ' ,   ' U n k n o w n   s t r e a m   f i l e   t y p e ' ) ; 
 E ( ' E R R _ V 8 B R E A K I T E R A T O R ' ,   ' F u l l   I C U   d a t a   n o t   i n s t a l l e d .   '   + 
     ' S e e   h t t p s : / / g i t h u b . c o m / n o d e j s / n o d e / w i k i / I n t l ' ) ; 
 E ( ' E R R _ V A L I D _ P E R F O R M A N C E _ E N T R Y _ T Y P E ' , 
     ' A t   l e a s t   o n e   v a l i d   p e r f o r m a n c e   e n t r y   t y p e   i s   r e q u i r e d ' ) ; 
 E ( ' E R R _ V A L U E _ O U T _ O F _ R A N G E ' ,   ( s t a r t ,   e n d ,   v a l u e )   = >   { 
     r e t u r n   ` T h e   v a l u e   o f   " $ { s t a r t } "   m u s t   b e   $ { e n d } .   R e c e i v e d   " $ { v a l u e } " ` ; 
 } ) ; 
 E ( ' E R R _ Z L I B _ B I N D I N G _ C L O S E D ' ,   ' z l i b   b i n d i n g   c l o s e d ' ) ; 
 E ( ' E R R _ Z L I B _ I N I T I A L I Z A T I O N _ F A I L E D ' ,   ' I n i t i a l i z a t i o n   f a i l e d ' ) ; 
 
 f u n c t i o n   s y s E r r o r ( d e f a u l t M e s s a g e )   { 
     r e t u r n   f u n c t i o n ( c o d e , 
                                     s y s c a l l , 
                                     p a t h , 
                                     d e s t , 
                                     m e s s a g e   =   d e f a u l t M e s s a g e )   { 
         i f   ( c o d e   ! = =   u n d e f i n e d ) 
             m e s s a g e   + =   ` :   $ { c o d e } ` ; 
         i f   ( s y s c a l l   ! = =   u n d e f i n e d )   { 
             i f   ( c o d e   = = =   u n d e f i n e d ) 
                 m e s s a g e   + =   ' : ' ; 
             m e s s a g e   + =   `   [ $ { s y s c a l l } ] ` ; 
         } 
         i f   ( p a t h   ! = =   u n d e f i n e d )   { 
             m e s s a g e   + =   ` :   $ { p a t h } ` ; 
             i f   ( d e s t   ! = =   u n d e f i n e d ) 
                 m e s s a g e   + =   `   = >   $ { d e s t } ` ; 
         } 
         r e t u r n   m e s s a g e ; 
     } ; 
 } 
 
 f u n c t i o n   i n v a l i d A r g T y p e ( n a m e ,   e x p e c t e d ,   a c t u a l )   { 
     i n t e r n a l A s s e r t ( n a m e ,   ' n a m e   i s   r e q u i r e d ' ) ; 
 
     / /   d e t e r m i n e r :   ' m u s t   b e '   o r   ' m u s t   n o t   b e ' 
     l e t   d e t e r m i n e r ; 
     i f   ( t y p e o f   e x p e c t e d   = = =   ' s t r i n g '   & &   e x p e c t e d . s t a r t s W i t h ( ' n o t   ' ) )   { 
         d e t e r m i n e r   =   ' m u s t   n o t   b e ' ; 
         e x p e c t e d   =   e x p e c t e d . r e p l a c e ( / ^ n o t   / ,   ' ' ) ; 
     }   e l s e   { 
         d e t e r m i n e r   =   ' m u s t   b e ' ; 
     } 
 
     l e t   m s g ; 
     i f   ( A r r a y . i s A r r a y ( n a m e ) )   { 
         v a r   n a m e s   =   n a m e . m a p ( ( v a l )   = >   ` " $ { v a l } " ` ) . j o i n ( ' ,   ' ) ; 
         m s g   =   ` T h e   $ { n a m e s }   a r g u m e n t s   $ { d e t e r m i n e r }   $ { o n e O f ( e x p e c t e d ,   ' t y p e ' ) } ` ; 
     }   e l s e   i f   ( n a m e . e n d s W i t h ( '   a r g u m e n t ' ) )   { 
         / /   f o r   t h e   c a s e   l i k e   ' f i r s t   a r g u m e n t ' 
         m s g   =   ` T h e   $ { n a m e }   $ { d e t e r m i n e r }   $ { o n e O f ( e x p e c t e d ,   ' t y p e ' ) } ` ; 
     }   e l s e   { 
         c o n s t   t y p e   =   n a m e . i n c l u d e s ( ' . ' )   ?   ' p r o p e r t y '   :   ' a r g u m e n t ' ; 
         m s g   =   ` T h e   " $ { n a m e } "   $ { t y p e }   $ { d e t e r m i n e r }   $ { o n e O f ( e x p e c t e d ,   ' t y p e ' ) } ` ; 
     } 
 
     / /   i f   a c t u a l   v a l u e   r e c e i v e d ,   o u t p u t   i t 
     i f   ( a r g u m e n t s . l e n g t h   > =   3 )   { 
         m s g   + =   ` .   R e c e i v e d   t y p e   $ { a c t u a l   ! = =   n u l l   ?   t y p e o f   a c t u a l   :   ' n u l l ' } ` ; 
     } 
     r e t u r n   m s g ; 
 } 
 
 f u n c t i o n   m i s s i n g A r g s ( . . . a r g s )   { 
     i n t e r n a l A s s e r t ( a r g s . l e n g t h   >   0 ,   ' A t   l e a s t   o n e   a r g   n e e d s   t o   b e   s p e c i f i e d ' ) ; 
     l e t   m s g   =   ' T h e   ' ; 
     c o n s t   l e n   =   a r g s . l e n g t h ; 
     a r g s   =   a r g s . m a p ( ( a )   = >   ` " $ { a } " ` ) ; 
     s w i t c h   ( l e n )   { 
         c a s e   1 : 
             m s g   + =   ` $ { a r g s [ 0 ] }   a r g u m e n t ` ; 
             b r e a k ; 
         c a s e   2 : 
             m s g   + =   ` $ { a r g s [ 0 ] }   a n d   $ { a r g s [ 1 ] }   a r g u m e n t s ` ; 
             b r e a k ; 
         d e f a u l t : 
             m s g   + =   a r g s . s l i c e ( 0 ,   l e n   -   1 ) . j o i n ( ' ,   ' ) ; 
             m s g   + =   ` ,   a n d   $ { a r g s [ l e n   -   1 ] }   a r g u m e n t s ` ; 
             b r e a k ; 
     } 
     r e t u r n   ` $ { m s g }   m u s t   b e   s p e c i f i e d ` ; 
 } 
 
 f u n c t i o n   o n e O f ( e x p e c t e d ,   t h i n g )   { 
     i n t e r n a l A s s e r t ( e x p e c t e d ,   ' e x p e c t e d   i s   r e q u i r e d ' ) ; 
     i n t e r n a l A s s e r t ( t y p e o f   t h i n g   = = =   ' s t r i n g ' ,   ' t h i n g   i s   r e q u i r e d ' ) ; 
     i f   ( A r r a y . i s A r r a y ( e x p e c t e d ) )   { 
         c o n s t   l e n   =   e x p e c t e d . l e n g t h ; 
         i n t e r n a l A s s e r t ( l e n   >   0 , 
                                       ' A t   l e a s t   o n e   e x p e c t e d   v a l u e   n e e d s   t o   b e   s p e c i f i e d ' ) ; 
         e x p e c t e d   =   e x p e c t e d . m a p ( ( i )   = >   S t r i n g ( i ) ) ; 
         i f   ( l e n   >   2 )   { 
             r e t u r n   ` o n e   o f   $ { t h i n g }   $ { e x p e c t e d . s l i c e ( 0 ,   l e n   -   1 ) . j o i n ( ' ,   ' ) } ,   o r   `   + 
                           e x p e c t e d [ l e n   -   1 ] ; 
         }   e l s e   i f   ( l e n   = = =   2 )   { 
             r e t u r n   ` o n e   o f   $ { t h i n g }   $ { e x p e c t e d [ 0 ] }   o r   $ { e x p e c t e d [ 1 ] } ` ; 
         }   e l s e   { 
             r e t u r n   ` o f   $ { t h i n g }   $ { e x p e c t e d [ 0 ] } ` ; 
         } 
     }   e l s e   { 
         r e t u r n   ` o f   $ { t h i n g }   $ { S t r i n g ( e x p e c t e d ) } ` ; 
     } 
 } 
 
 f u n c t i o n   b u f f e r O u t O f B o u n d s ( n a m e ,   i s W r i t i n g )   { 
     i f   ( i s W r i t i n g )   { 
         r e t u r n   ' A t t e m p t   t o   w r i t e   o u t s i d e   b u f f e r   b o u n d s ' ; 
     }   e l s e   { 
         r e t u r n   ` " $ { n a m e } "   i s   o u t s i d e   o f   b u f f e r   b o u n d s ` ; 
     } 
 } 
 
 f u n c t i o n   i n v a l i d C h a r ( n a m e ,   f i e l d )   { 
     l e t   m s g   =   ` I n v a l i d   c h a r a c t e r   i n   $ { n a m e } ` ; 
     i f   ( f i e l d )   { 
         m s g   + =   `   [ " $ { f i e l d } " ] ` ; 
     } 
     r e t u r n   m s g ; 
 } 
 
 } ) ; .  T   ��
 N O D E _ M O D U L E S / I N T E R N A L / F S . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ' u s e   s t r i c t ' ; 
 
 c o n s t   {   B u f f e r   }   =   r e q u i r e ( ' b u f f e r ' ) ; 
 c o n s t   {   W r i t a b l e   }   =   r e q u i r e ( ' s t r e a m ' ) ; 
 c o n s t   f s   =   r e q u i r e ( ' f s ' ) ; 
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' ) ; 
 
 c o n s t   { 
     O _ A P P E N D , 
     O _ C R E A T , 
     O _ E X C L , 
     O _ R D O N L Y , 
     O _ R D W R , 
     O _ S Y N C , 
     O _ T R U N C , 
     O _ W R O N L Y 
 }   =   p r o c e s s . b i n d i n g ( ' c o n s t a n t s ' ) . f s ; 
 
 f u n c t i o n   a s s e r t E n c o d i n g ( e n c o d i n g )   { 
     i f   ( e n c o d i n g   & &   ! B u f f e r . i s E n c o d i n g ( e n c o d i n g ) )   { 
         t h r o w   n e w   E r r o r ( ` U n k n o w n   e n c o d i n g :   $ { e n c o d i n g } ` ) ; 
     } 
 } 
 
 f u n c t i o n   s t r i n g T o F l a g s ( f l a g )   { 
     i f   ( t y p e o f   f l a g   = = =   ' n u m b e r ' )   { 
         r e t u r n   f l a g ; 
     } 
 
     s w i t c h   ( f l a g )   { 
         c a s e   ' r '   :   r e t u r n   O _ R D O N L Y ; 
         c a s e   ' r s '   :   / /   F a l l   t h r o u g h . 
         c a s e   ' s r '   :   r e t u r n   O _ R D O N L Y   |   O _ S Y N C ; 
         c a s e   ' r + '   :   r e t u r n   O _ R D W R ; 
         c a s e   ' r s + '   :   / /   F a l l   t h r o u g h . 
         c a s e   ' s r + '   :   r e t u r n   O _ R D W R   |   O _ S Y N C ; 
 
         c a s e   ' w '   :   r e t u r n   O _ T R U N C   |   O _ C R E A T   |   O _ W R O N L Y ; 
         c a s e   ' w x '   :   / /   F a l l   t h r o u g h . 
         c a s e   ' x w '   :   r e t u r n   O _ T R U N C   |   O _ C R E A T   |   O _ W R O N L Y   |   O _ E X C L ; 
 
         c a s e   ' w + '   :   r e t u r n   O _ T R U N C   |   O _ C R E A T   |   O _ R D W R ; 
         c a s e   ' w x + ' :   / /   F a l l   t h r o u g h . 
         c a s e   ' x w + ' :   r e t u r n   O _ T R U N C   |   O _ C R E A T   |   O _ R D W R   |   O _ E X C L ; 
 
         c a s e   ' a '   :   r e t u r n   O _ A P P E N D   |   O _ C R E A T   |   O _ W R O N L Y ; 
         c a s e   ' a x '   :   / /   F a l l   t h r o u g h . 
         c a s e   ' x a '   :   r e t u r n   O _ A P P E N D   |   O _ C R E A T   |   O _ W R O N L Y   |   O _ E X C L ; 
 
         c a s e   ' a + '   :   r e t u r n   O _ A P P E N D   |   O _ C R E A T   |   O _ R D W R ; 
         c a s e   ' a x + ' :   / /   F a l l   t h r o u g h . 
         c a s e   ' x a + ' :   r e t u r n   O _ A P P E N D   |   O _ C R E A T   |   O _ R D W R   |   O _ E X C L ; 
     } 
 
     t h r o w   n e w   E r r o r ( ' U n k n o w n   f i l e   o p e n   f l a g :   '   +   f l a g ) ; 
 } 
 
 / /   T e m p o r a r y   h a c k   f o r   p r o c e s s . s t d o u t   a n d   p r o c e s s . s t d e r r   w h e n   p i p e d   t o   f i l e s . 
 f u n c t i o n   S y n c W r i t e S t r e a m ( f d ,   o p t i o n s )   { 
     W r i t a b l e . c a l l ( t h i s ) ; 
 
     o p t i o n s   =   o p t i o n s   | |   { } ; 
 
     t h i s . f d   =   f d ; 
     t h i s . r e a d a b l e   =   f a l s e ; 
     t h i s . a u t o C l o s e   =   o p t i o n s . a u t o C l o s e   = = =   u n d e f i n e d   ?   t r u e   :   o p t i o n s . a u t o C l o s e ; 
 
     t h i s . o n ( ' e n d ' ,   ( )   = >   t h i s . _ d e s t r o y ( ) ) ; 
 } 
 
 u t i l . i n h e r i t s ( S y n c W r i t e S t r e a m ,   W r i t a b l e ) ; 
 
 S y n c W r i t e S t r e a m . p r o t o t y p e . _ w r i t e   =   f u n c t i o n ( c h u n k ,   e n c o d i n g ,   c b )   { 
     f s . w r i t e S y n c ( t h i s . f d ,   c h u n k ,   0 ,   c h u n k . l e n g t h ) ; 
     c b ( ) ; 
     r e t u r n   t r u e ; 
 } ; 
 
 S y n c W r i t e S t r e a m . p r o t o t y p e . _ d e s t r o y   =   f u n c t i o n ( )   { 
     i f   ( t h i s . f d   = = =   n u l l )   / /   a l r e a d y   d e s t r o y ( ) e d 
         r e t u r n ; 
 
     i f   ( t h i s . a u t o C l o s e ) 
         f s . c l o s e S y n c ( t h i s . f d ) ; 
 
     t h i s . f d   =   n u l l ; 
     r e t u r n   t r u e ; 
 } ; 
 
 S y n c W r i t e S t r e a m . p r o t o t y p e . d e s t r o y S o o n   = 
 S y n c W r i t e S t r e a m . p r o t o t y p e . d e s t r o y   =   f u n c t i o n ( )   { 
     t h i s . _ d e s t r o y ( ) ; 
     t h i s . e m i t ( ' c l o s e ' ) ; 
     r e t u r n   t r u e ; 
 } ; 
 
 m o d u l e . e x p o r t s   =   { 
     a s s e r t E n c o d i n g , 
     s t r i n g T o F l a g s , 
     S y n c W r i t e S t r e a m , 
     r e a l p a t h C a c h e K e y :   S y m b o l ( ' r e a l p a t h C a c h e K e y ' ) 
 } ; 
 
 } ) ;   0   \   ��
 N O D E _ M O D U L E S / I N T E R N A L / M O D U L E . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ' u s e   s t r i c t ' ;   
   
 / /   I n v o k e   w i t h   m a k e R e q u i r e F u n c t i o n ( m o d u l e )   w h e r e   | m o d u l e |   i s   t h e   M o d u l e   o b j e c t   
 / /   t o   u s e   a s   t h e   c o n t e x t   f o r   t h e   r e q u i r e ( )   f u n c t i o n .   
 f u n c t i o n   m a k e R e q u i r e F u n c t i o n ( m o d )   {   
     c o n s t   M o d u l e   =   m o d . c o n s t r u c t o r ;   
   
     f u n c t i o n   r e q u i r e ( p a t h )   {   
         t r y   {   
             e x p o r t s . r e q u i r e D e p t h   + =   1 ;   
             r e t u r n   m o d . r e q u i r e ( p a t h ) ;   
         }   f i n a l l y   {   
             e x p o r t s . r e q u i r e D e p t h   - =   1 ;   
         }   
     }   
   
     f u n c t i o n   r e s o l v e ( r e q u e s t ,   o p t i o n s )   {   
         r e t u r n   M o d u l e . _ r e s o l v e F i l e n a m e ( r e q u e s t ,   m o d ,   f a l s e ,   o p t i o n s ) ;   
     }   
   
     r e q u i r e . r e s o l v e   =   r e s o l v e ;   
   
     f u n c t i o n   p a t h s ( r e q u e s t )   {   
         r e t u r n   M o d u l e . _ r e s o l v e L o o k u p P a t h s ( r e q u e s t ,   m o d ,   t r u e ) ;   
     }   
   
     r e s o l v e . p a t h s   =   p a t h s ;   
   
     r e q u i r e . m a i n   =   p r o c e s s . m a i n M o d u l e ;   
   
     / /   E n a b l e   s u p p o r t   t o   a d d   e x t r a   e x t e n s i o n   t y p e s .   
     r e q u i r e . e x t e n s i o n s   =   M o d u l e . _ e x t e n s i o n s ;   
   
     r e q u i r e . c a c h e   =   M o d u l e . _ c a c h e ;   
   
     r e t u r n   r e q u i r e ;   
 }   
   
 / * *   
   *   R e m o v e   b y t e   o r d e r   m a r k e r .   T h i s   c a t c h e s   E F   B B   B F   ( t h e   U T F - 8   B O M )   
   *   b e c a u s e   t h e   b u f f e r - t o - s t r i n g   c o n v e r s i o n   i n   ` f s . r e a d F i l e S y n c ( ) `   
   *   t r a n s l a t e s   i t   t o   F E F F ,   t h e   U T F - 1 6   B O M .   
   * /   
 f u n c t i o n   s t r i p B O M ( c o n t e n t )   {   
     i f   ( c o n t e n t . c h a r C o d e A t ( 0 )   = = =   0 x F E F F )   {   
         c o n t e n t   =   c o n t e n t . s l i c e ( 1 ) ;   
     }   
     r e t u r n   c o n t e n t ;   
 }   
   
 / * *   
   *   F i n d   e n d   o f   s h e b a n g   l i n e   a n d   s l i c e   i t   o f f   
   * /   
 f u n c t i o n   s t r i p S h e b a n g ( c o n t e n t )   {   
     / /   R e m o v e   s h e b a n g   
     v a r   c o n t L e n   =   c o n t e n t . l e n g t h ;   
     i f   ( c o n t L e n   > =   2 )   {   
         i f   ( c o n t e n t . c h a r C o d e A t ( 0 )   = = =   3 5 / * # * /   & &   
                 c o n t e n t . c h a r C o d e A t ( 1 )   = = =   3 3 / * ! * / )   {   
             i f   ( c o n t L e n   = = =   2 )   {   
                 / /   E x a c t   m a t c h   
                 c o n t e n t   =   ' ' ;   
             }   e l s e   {   
                 / /   F i n d   e n d   o f   s h e b a n g   l i n e   a n d   s l i c e   i t   o f f   
                 v a r   i   =   2 ;   
                 f o r   ( ;   i   <   c o n t L e n ;   + + i )   {   
                     v a r   c o d e   =   c o n t e n t . c h a r C o d e A t ( i ) ;   
                     i f   ( c o d e   = = =   1 0 / * \ n * /   | |   c o d e   = = =   1 3 / * \ r * / )   
                         b r e a k ;   
                 }   
                 i f   ( i   = = =   c o n t L e n )   
                     c o n t e n t   =   ' ' ;   
                 e l s e   {   
                     / /   N o t e   t h a t   t h i s   a c t u a l l y   i n c l u d e s   t h e   n e w l i n e   c h a r a c t e r ( s )   i n   t h e   
                     / /   n e w   o u t p u t .   T h i s   d u p l i c a t e s   t h e   b e h a v i o r   o f   t h e   r e g u l a r   e x p r e s s i o n   
                     / /   t h a t   w a s   p r e v i o u s l y   u s e d   t o   r e p l a c e   t h e   s h e b a n g   l i n e   
                     c o n t e n t   =   c o n t e n t . s l i c e ( i ) ;   
                 }   
             }   
         }   
     }   
     r e t u r n   c o n t e n t ;   
 }   
   
 c o n s t   b u i l t i n L i b s   =   [   
     ' a s s e r t ' ,   ' a s y n c _ h o o k s ' ,   ' b u f f e r ' ,   ' c h i l d _ p r o c e s s ' ,   ' c l u s t e r ' ,   ' c r y p t o ' ,   
     ' d g r a m ' ,   ' d n s ' ,   ' d o m a i n ' ,   ' e v e n t s ' ,   ' f s ' ,   ' h t t p ' ,   ' h t t p s ' ,   ' n e t ' ,   
     ' o s ' ,   ' p a t h ' ,   ' p e r f _ h o o k s ' ,   ' p u n y c o d e ' ,   ' q u e r y s t r i n g ' ,   ' r e a d l i n e ' ,   ' r e p l ' ,   
     ' s t r e a m ' ,   ' s t r i n g _ d e c o d e r ' ,   ' t l s ' ,   ' t t y ' ,   ' u r l ' ,   ' u t i l ' ,   ' v 8 ' ,   ' v m ' ,   ' z l i b '   
 ] ;   
   
 / *   S y N o d e   
 c o n s t   {   e x p o s e H T T P 2   }   =   p r o c e s s . b i n d i n g ( ' c o n f i g ' ) ;   
 i f   ( e x p o s e H T T P 2 )   
     b u i l t i n L i b s . p u s h ( ' h t t p 2 ' ) ;   
   
 i f   ( t y p e o f   p r o c e s s . b i n d i n g ( ' i n s p e c t o r ' ) . c o n n e c t   = = =   ' f u n c t i o n ' )   {   
     b u i l t i n L i b s . p u s h ( ' i n s p e c t o r ' ) ;   
     b u i l t i n L i b s . s o r t ( ) ;   
 }   
 * /   
   
 f u n c t i o n   a d d B u i l t i n L i b s T o O b j e c t ( o b j e c t )   {   
     / /   M a k e   b u i l t - i n   m o d u l e s   a v a i l a b l e   d i r e c t l y   ( l o a d e d   l a z i l y ) .   
     b u i l t i n L i b s . f o r E a c h ( ( n a m e )   = >   {   
         / /   G o a l s   o f   t h i s   m e c h a n i s m   a r e :   
         / /   -   L a z y   l o a d i n g   o f   b u i l t - i n   m o d u l e s   
         / /   -   H a v i n g   a l l   b u i l t - i n   m o d u l e s   a v a i l a b l e   a s   n o n - e n u m e r a b l e   p r o p e r t i e s   
         / /   -   A l l o w i n g   t h e   u s e r   t o   r e - a s s i g n   t h e s e   v a r i a b l e s   a s   i f   t h e r e   w e r e   n o   
         / /       p r e - e x i s t i n g   g l o b a l s   w i t h   t h e   s a m e   n a m e .   
   
         c o n s t   s e t R e a l   =   ( v a l )   = >   {   
             / /   D e l e t i n g   t h e   p r o p e r t y   b e f o r e   r e - a s s i g n i n g   i t   d i s a b l e s   t h e   
             / /   g e t t e r / s e t t e r   m e c h a n i s m .   
             d e l e t e   o b j e c t [ n a m e ] ;   
             o b j e c t [ n a m e ]   =   v a l ;   
         } ;   
   
         O b j e c t . d e f i n e P r o p e r t y ( o b j e c t ,   n a m e ,   {   
             g e t :   ( )   = >   {   
                 c o n s t   l i b   =   r e q u i r e ( n a m e ) ;   
   
                 / /   D i s a b l e   t h e   c u r r e n t   g e t t e r / s e t t e r   a n d   s e t   u p   a   n e w   
                 / /   n o n - e n u m e r a b l e   p r o p e r t y .   
                 d e l e t e   o b j e c t [ n a m e ] ;   
                 O b j e c t . d e f i n e P r o p e r t y ( o b j e c t ,   n a m e ,   {   
                     g e t :   ( )   = >   l i b ,   
                     s e t :   s e t R e a l ,   
                     c o n f i g u r a b l e :   t r u e ,   
                     e n u m e r a b l e :   f a l s e   
                 } ) ;   
   
                 r e t u r n   l i b ;   
             } ,   
             s e t :   s e t R e a l ,   
             c o n f i g u r a b l e :   t r u e ,   
             e n u m e r a b l e :   f a l s e   
         } ) ;   
     } ) ;   
 }   
   
 m o d u l e . e x p o r t s   =   e x p o r t s   =   {   
     a d d B u i l t i n L i b s T o O b j e c t ,   
     b u i l t i n L i b s ,   
     m a k e R e q u i r e F u n c t i o n ,   
     r e q u i r e D e p t h :   0 ,   
     s t r i p B O M ,   
     s t r i p S h e b a n g   
 } ;   
 
 } ) ; j	  h   ��
 N O D E _ M O D U L E S / I N T E R N A L / Q U E R Y S T R I N G . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ' u s e   s t r i c t ' ; 
 
 c o n s t   h e x T a b l e   =   n e w   A r r a y ( 2 5 6 ) ; 
 f o r   ( v a r   i   =   0 ;   i   <   2 5 6 ;   + + i ) 
     h e x T a b l e [ i ]   =   ' % '   +   ( ( i   <   1 6   ?   ' 0 '   :   ' ' )   +   i . t o S t r i n g ( 1 6 ) ) . t o U p p e r C a s e ( ) ; 
 
 c o n s t   i s H e x T a b l e   =   [ 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   / /   0   -   1 5 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   / /   1 6   -   3 1 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   / /   3 2   -   4 7 
     1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   / /   4 8   -   6 3 
     0 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   / /   6 4   -   7 9 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   / /   8 0   -   9 5 
     0 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   / /   9 6   -   1 1 1 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   / /   1 1 2   -   1 2 7 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   / /   1 2 8   . . . 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 , 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 , 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 , 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 , 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 , 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 , 
     0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0 ,   0     / /   . . .   2 5 6 
 ] ; 
 
 m o d u l e . e x p o r t s   =   { 
     h e x T a b l e , 
     i s H e x T a b l e 
 } ; 
 
 } ) ;   "  t   ��
 N O D E _ M O D U L E S / I N T E R N A L / S T R E A M S / B U F F E R L I S T . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ' u s e   s t r i c t ' ;   
   
 c o n s t   B u f f e r   =   r e q u i r e ( ' b u f f e r ' ) . B u f f e r ;   
   
 m o d u l e . e x p o r t s   =   B u f f e r L i s t ;   
   
 f u n c t i o n   B u f f e r L i s t ( )   {   
     t h i s . h e a d   =   n u l l ;   
     t h i s . t a i l   =   n u l l ;   
     t h i s . l e n g t h   =   0 ;   
 }   
   
 B u f f e r L i s t . p r o t o t y p e . p u s h   =   f u n c t i o n ( v )   {   
     c o n s t   e n t r y   =   {   d a t a :   v ,   n e x t :   n u l l   } ;   
     i f   ( t h i s . l e n g t h   >   0 )   
         t h i s . t a i l . n e x t   =   e n t r y ;   
     e l s e   
         t h i s . h e a d   =   e n t r y ;   
     t h i s . t a i l   =   e n t r y ;   
     + + t h i s . l e n g t h ;   
 } ;   
   
 B u f f e r L i s t . p r o t o t y p e . u n s h i f t   =   f u n c t i o n ( v )   {   
     c o n s t   e n t r y   =   {   d a t a :   v ,   n e x t :   t h i s . h e a d   } ;   
     i f   ( t h i s . l e n g t h   = = =   0 )   
         t h i s . t a i l   =   e n t r y ;   
     t h i s . h e a d   =   e n t r y ;   
     + + t h i s . l e n g t h ;   
 } ;   
   
 B u f f e r L i s t . p r o t o t y p e . s h i f t   =   f u n c t i o n ( )   {   
     i f   ( t h i s . l e n g t h   = = =   0 )   
         r e t u r n ;   
     c o n s t   r e t   =   t h i s . h e a d . d a t a ;   
     i f   ( t h i s . l e n g t h   = = =   1 )   
         t h i s . h e a d   =   t h i s . t a i l   =   n u l l ;   
     e l s e   
         t h i s . h e a d   =   t h i s . h e a d . n e x t ;   
     - - t h i s . l e n g t h ;   
     r e t u r n   r e t ;   
 } ;   
   
 B u f f e r L i s t . p r o t o t y p e . c l e a r   =   f u n c t i o n ( )   {   
     t h i s . h e a d   =   t h i s . t a i l   =   n u l l ;   
     t h i s . l e n g t h   =   0 ;   
 } ;   
   
 B u f f e r L i s t . p r o t o t y p e . j o i n   =   f u n c t i o n ( s )   {   
     i f   ( t h i s . l e n g t h   = = =   0 )   
         r e t u r n   ' ' ;   
     v a r   p   =   t h i s . h e a d ;   
     v a r   r e t   =   ' '   +   p . d a t a ;   
     w h i l e   ( p   =   p . n e x t )   
         r e t   + =   s   +   p . d a t a ;   
     r e t u r n   r e t ;   
 } ;   
   
 B u f f e r L i s t . p r o t o t y p e . c o n c a t   =   f u n c t i o n ( n )   {   
     i f   ( t h i s . l e n g t h   = = =   0 )   
         r e t u r n   B u f f e r . a l l o c ( 0 ) ;   
     i f   ( t h i s . l e n g t h   = = =   1 )   
         r e t u r n   t h i s . h e a d . d a t a ;   
     c o n s t   r e t   =   B u f f e r . a l l o c U n s a f e ( n   > > >   0 ) ;   
     v a r   p   =   t h i s . h e a d ;   
     v a r   i   =   0 ;   
     w h i l e   ( p )   {   
         p . d a t a . c o p y ( r e t ,   i ) ;   
         i   + =   p . d a t a . l e n g t h ;   
         p   =   p . n e x t ;   
     }   
     r e t u r n   r e t ;   
 } ;   
 
 } ) ;   &  X   ��
 N O D E _ M O D U L E S / I N T E R N A L / U T I L . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ' u s e   s t r i c t ' ;   
 d e b u g g e r ;   
 c o n s t   b i n d i n g   =   p r o c e s s . b i n d i n g ( ' u t i l ' ) ;   
 / *   O r e l   
 c o n s t   p r e f i x   =   ` ( $ { p r o c e s s . r e l e a s e . n a m e } : $ { p r o c e s s . p i d } )   ` ;   
   
 c o n s t   k A r r o w M e s s a g e P r i v a t e S y m b o l I n d e x   =   b i n d i n g [ ' a r r o w _ m e s s a g e _ p r i v a t e _ s y m b o l ' ] ;   
 c o n s t   k D e c o r a t e d P r i v a t e S y m b o l I n d e x   =   b i n d i n g [ ' d e c o r a t e d _ p r i v a t e _ s y m b o l ' ] ;   
   
 e x p o r t s . g e t H i d d e n V a l u e   =   b i n d i n g . g e t H i d d e n V a l u e ;   
 e x p o r t s . s e t H i d d e n V a l u e   =   b i n d i n g . s e t H i d d e n V a l u e ;   
 * /   
 / /   T h e   ` b u f f e r `   m o d u l e   u s e s   t h i s .   D e f i n i n g   i t   h e r e   i n s t e a d   o f   i n   t h e   p u b l i c   
 / /   ` u t i l `   m o d u l e   m a k e s   i t   a c c e s s i b l e   w i t h o u t   h a v i n g   t o   ` r e q u i r e ( ' u t i l ' ) `   t h e r e .   
 e x p o r t s . c u s t o m I n s p e c t S y m b o l   =   S y m b o l ( ' u t i l . i n s p e c t . c u s t o m ' ) ;   
   
 / /   A l l   t h e   i n t e r n a l   d e p r e c a t i o n s   h a v e   t o   u s e   t h i s   f u n c t i o n   o n l y ,   a s   t h i s   w i l l   
 / /   p r e p e n d   t h e   p r e f i x   t o   t h e   a c t u a l   m e s s a g e .   
 e x p o r t s . d e p r e c a t e   =   f u n c t i o n ( f n ,   m s g )   {   
     r e t u r n   e x p o r t s . _ d e p r e c a t e ( f n ,   m s g ) ;   
 } ;   
   
 / *   O r e l   
 e x p o r t s . e r r o r   =   f u n c t i o n ( m s g )   {   
     c o n s t   f m t   =   ` $ { p r e f i x } $ { m s g } ` ;   
     i f   ( a r g u m e n t s . l e n g t h   >   1 )   {   
         c o n s t   a r g s   =   n e w   A r r a y ( a r g u m e n t s . l e n g t h ) ;   
         a r g s [ 0 ]   =   f m t ;   
         f o r   ( l e t   i   =   1 ;   i   <   a r g u m e n t s . l e n g t h ;   + + i )   
             a r g s [ i ]   =   a r g u m e n t s [ i ] ;   
         c o n s o l e . e r r o r . a p p l y ( c o n s o l e ,   a r g s ) ;   
     }   e l s e   {   
         c o n s o l e . e r r o r ( f m t ) ;   
     }   
 } ;   
   
 e x p o r t s . t r a c e   =   f u n c t i o n ( m s g )   {   
     c o n s o l e . t r a c e ( ` $ { p r e f i x } $ { m s g } ` ) ;   
 } ; * /   
   
 / /   M a r k   t h a t   a   m e t h o d   s h o u l d   n o t   b e   u s e d .   
 / /   R e t u r n s   a   m o d i f i e d   f u n c t i o n   w h i c h   w a r n s   o n c e   b y   d e f a u l t .   
 / /   I f   - - n o - d e p r e c a t i o n   i s   s e t ,   t h e n   i t   i s   a   n o - o p .   
 e x p o r t s . _ d e p r e c a t e   =   f u n c t i o n ( f n ,   m s g )   {   
     / /   A l l o w   f o r   d e p r e c a t i n g   t h i n g s   i n   t h e   p r o c e s s   o f   s t a r t i n g   u p .   
     i f   ( g l o b a l . p r o c e s s   = = =   u n d e f i n e d )   {   
         r e t u r n   f u n c t i o n ( )   {   
             r e t u r n   e x p o r t s . _ d e p r e c a t e ( f n ,   m s g ) . a p p l y ( t h i s ,   a r g u m e n t s ) ;   
         } ;   
     }   
   
     i f   ( p r o c e s s . n o D e p r e c a t i o n   = = =   t r u e )   {   
         r e t u r n   f n ;   
     }   
   
     v a r   w a r n e d   =   f a l s e ;   
     f u n c t i o n   d e p r e c a t e d ( )   {   
         i f   ( ! w a r n e d )   {   
             w a r n e d   =   t r u e ;   
             p r o c e s s . e m i t W a r n i n g ( m s g ,   ' D e p r e c a t i o n W a r n i n g ' ,   d e p r e c a t e d ) ;   
         }   
         i f   ( n e w . t a r g e t )   {   
             r e t u r n   R e f l e c t . c o n s t r u c t ( f n ,   a r g u m e n t s ,   n e w . t a r g e t ) ;   
         }   
         r e t u r n   f n . a p p l y ( t h i s ,   a r g u m e n t s ) ;   
     }   
   
     / /   T h e   w r a p p e r   w i l l   k e e p   t h e   s a m e   p r o t o t y p e   a s   f n   t o   m a i n t a i n   p r o t o t y p e   c h a i n   
     O b j e c t . s e t P r o t o t y p e O f ( d e p r e c a t e d ,   f n ) ;   
     i f   ( f n . p r o t o t y p e )   {   
         / /   S e t t i n g   t h i s   ( r a t h e r   t h a n   u s i n g   O b j e c t . s e t P r o t o t y p e ,   a s   a b o v e )   e n s u r e s   
         / /   t h a t   c a l l i n g   t h e   u n w r a p p e d   c o n s t r u c t o r   g i v e s   a n   i n s t a n c e o f   t h e   w r a p p e d   
         / /   c o n s t r u c t o r .   
         d e p r e c a t e d . p r o t o t y p e   =   f n . p r o t o t y p e ;   
     }   
   
     r e t u r n   d e p r e c a t e d ;   
 } ;   
 / *   O r e l   
 e x p o r t s . d e c o r a t e E r r o r S t a c k   =   f u n c t i o n   d e c o r a t e E r r o r S t a c k ( e r r )   {   
     i f   ( ! ( e x p o r t s . i s E r r o r ( e r r )   & &   e r r . s t a c k )   | |   
             e x p o r t s . g e t H i d d e n V a l u e ( e r r ,   k D e c o r a t e d P r i v a t e S y m b o l I n d e x )   = = =   t r u e )   
         r e t u r n ;   
   
     c o n s t   a r r o w   =   e x p o r t s . g e t H i d d e n V a l u e ( e r r ,   k A r r o w M e s s a g e P r i v a t e S y m b o l I n d e x ) ;   
   
     i f   ( a r r o w )   {   
         e r r . s t a c k   =   a r r o w   +   e r r . s t a c k ;   
         e x p o r t s . s e t H i d d e n V a l u e ( e r r ,   k D e c o r a t e d P r i v a t e S y m b o l I n d e x ,   t r u e ) ;   
     }   
 } ; * /   
   
 e x p o r t s . i s E r r o r   =   f u n c t i o n   i s E r r o r ( e )   {   
     r e t u r n   e x p o r t s . o b j e c t T o S t r i n g ( e )   = = =   ' [ o b j e c t   E r r o r ] '   | |   e   i n s t a n c e o f   E r r o r ;   
 } ;   
   
 e x p o r t s . o b j e c t T o S t r i n g   =   f u n c t i o n   o b j e c t T o S t r i n g ( o )   {   
     r e t u r n   O b j e c t . p r o t o t y p e . t o S t r i n g . c a l l ( o ) ;   
 } ;   
   
 / *   O r e l   
 c o n s t   n o C r y p t o   =   ! p r o c e s s . v e r s i o n s . o p e n s s l ;   
 * /   
 c o n s t   n o C r y p t o   =   f a l s e ;   
 e x p o r t s . a s s e r t C r y p t o   =   f u n c t i o n ( e x p o r t s )   {   
     i f   ( n o C r y p t o )   
         t h r o w   n e w   E r r o r ( ' N o d e . j s   i s   n o t   c o m p i l e d   w i t h   o p e n s s l   c r y p t o   s u p p o r t ' ) ;   
 } ;   
   
 e x p o r t s . k I s E n c o d i n g S y m b o l   =   S y m b o l ( ' n o d e . i s E n c o d i n g ' ) ;   
 e x p o r t s . n o r m a l i z e E n c o d i n g   =   f u n c t i o n   n o r m a l i z e E n c o d i n g ( e n c )   {   
     i f   ( ! e n c )   r e t u r n   ' u t f 8 ' ;   
     v a r   l o w ;   
     f o r   ( ; ; )   {   
         s w i t c h   ( e n c )   {   
             c a s e   ' u t f 8 ' :   
             c a s e   ' u t f - 8 ' :   
                 r e t u r n   ' u t f 8 ' ;   
             c a s e   ' u c s 2 ' :   
             c a s e   ' u t f 1 6 l e ' :   
             c a s e   ' u c s - 2 ' :   
             c a s e   ' u t f - 1 6 l e ' :   
                 r e t u r n   ' u t f 1 6 l e ' ;   
             c a s e   ' b i n a r y ' :   
                 r e t u r n   ' l a t i n 1 ' ;   
             c a s e   ' b a s e 6 4 ' :   
             c a s e   ' a s c i i ' :   
             c a s e   ' l a t i n 1 ' :   
             c a s e   ' h e x ' :   
                 r e t u r n   e n c ;   
             d e f a u l t :   
                 i f   ( l o w )   r e t u r n ;   / /   u n d e f i n e d   
                 e n c   =   ( ' '   +   e n c ) . t o L o w e r C a s e ( ) ;   
                 l o w   =   t r u e ;   
         }   
     }   
 } ;   
   
 / /   F i l t e r s   d u p l i c a t e   s t r i n g s .   U s e d   t o   s u p p o r t   f u n c t i o n s   i n   c r y p t o   a n d   t l s   
 / /   m o d u l e s .   I m p l e m e n t e d   s p e c i f i c a l l y   t o   m a i n t a i n   e x i s t i n g   b e h a v i o r s   i n   e a c h .   
 e x p o r t s . f i l t e r D u p l i c a t e S t r i n g s   =   f u n c t i o n   f i l t e r D u p l i c a t e S t r i n g s ( i t e m s ,   l o w )   {   
     i f   ( ! A r r a y . i s A r r a y ( i t e m s ) )   
         r e t u r n   [ ] ;   
     c o n s t   l e n   =   i t e m s . l e n g t h ;   
     i f   ( l e n   < =   1 )   
         r e t u r n   i t e m s ;   
     c o n s t   m a p   =   n e w   M a p ( ) ;   
     f o r   ( v a r   i   =   0 ;   i   <   l e n ;   i + + )   {   
         c o n s t   i t e m   =   i t e m s [ i ] ;   
         c o n s t   k e y   =   i t e m . t o L o w e r C a s e ( ) ;   
         i f   ( l o w )   {   
             m a p . s e t ( k e y ,   k e y ) ;   
         }   e l s e   {   
             i f   ( ! m a p . h a s ( k e y )   | |   m a p . g e t ( k e y )   < =   i t e m )   
                 m a p . s e t ( k e y ,   i t e m ) ;   
         }   
     }   
     r e t u r n   A r r a y . f r o m ( m a p . v a l u e s ( ) ) . s o r t ( ) ;   
 } ;   
   
 e x p o r t s . c a c h e d R e s u l t   =   f u n c t i o n   c a c h e d R e s u l t ( f n )   {   
     v a r   r e s u l t ;   
     r e t u r n   ( )   = >   {   
         i f   ( r e s u l t   = = =   u n d e f i n e d )   
             r e s u l t   =   f n ( ) ;   
         r e t u r n   r e s u l t ;   
     } ;   
 } ;   
 
 } ) ;   B�  L   ��
 N O D E _ M O D U L E S / M O D U L E . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / /   C o p y r i g h t   J o y e n t ,   I n c .   a n d   o t h e r   N o d e   c o n t r i b u t o r s .   
 / /   
 / /   P e r m i s s i o n   i s   h e r e b y   g r a n t e d ,   f r e e   o f   c h a r g e ,   t o   a n y   p e r s o n   o b t a i n i n g   a   
 / /   c o p y   o f   t h i s   s o f t w a r e   a n d   a s s o c i a t e d   d o c u m e n t a t i o n   f i l e s   ( t h e   
 / /   " S o f t w a r e " ) ,   t o   d e a l   i n   t h e   S o f t w a r e   w i t h o u t   r e s t r i c t i o n ,   i n c l u d i n g   
 / /   w i t h o u t   l i m i t a t i o n   t h e   r i g h t s   t o   u s e ,   c o p y ,   m o d i f y ,   m e r g e ,   p u b l i s h ,   
 / /   d i s t r i b u t e ,   s u b l i c e n s e ,   a n d / o r   s e l l   c o p i e s   o f   t h e   S o f t w a r e ,   a n d   t o   p e r m i t   
 / /   p e r s o n s   t o   w h o m   t h e   S o f t w a r e   i s   f u r n i s h e d   t o   d o   s o ,   s u b j e c t   t o   t h e   
 / /   f o l l o w i n g   c o n d i t i o n s :   
 / /   
 / /   T h e   a b o v e   c o p y r i g h t   n o t i c e   a n d   t h i s   p e r m i s s i o n   n o t i c e   s h a l l   b e   i n c l u d e d   
 / /   i n   a l l   c o p i e s   o r   s u b s t a n t i a l   p o r t i o n s   o f   t h e   S o f t w a r e .   
 / /   
 / /   T H E   S O F T W A R E   I S   P R O V I D E D   " A S   I S " ,   W I T H O U T   W A R R A N T Y   O F   A N Y   K I N D ,   E X P R E S S   
 / /   O R   I M P L I E D ,   I N C L U D I N G   B U T   N O T   L I M I T E D   T O   T H E   W A R R A N T I E S   O F   
 / /   M E R C H A N T A B I L I T Y ,   F I T N E S S   F O R   A   P A R T I C U L A R   P U R P O S E   A N D   N O N I N F R I N G E M E N T .   I N   
 / /   N O   E V E N T   S H A L L   T H E   A U T H O R S   O R   C O P Y R I G H T   H O L D E R S   B E   L I A B L E   F O R   A N Y   C L A I M ,   
 / /   D A M A G E S   O R   O T H E R   L I A B I L I T Y ,   W H E T H E R   I N   A N   A C T I O N   O F   C O N T R A C T ,   T O R T   O R   
 / /   O T H E R W I S E ,   A R I S I N G   F R O M ,   O U T   O F   O R   I N   C O N N E C T I O N   W I T H   T H E   S O F T W A R E   O R   T H E   
 / /   U S E   O R   O T H E R   D E A L I N G S   I N   T H E   S O F T W A R E .   
   
 ' u s e   s t r i c t ' ;   
   
 c o n s t   N a t i v e M o d u l e   =   r e q u i r e ( ' n a t i v e _ m o d u l e ' ) ;   
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
 c o n s t   i n t e r n a l M o d u l e   =   r e q u i r e ( ' i n t e r n a l / m o d u l e ' ) ;   
 / /   S y N o d e   c o n s t   {   g e t U R L F r o m F i l e P a t h   }   =   r e q u i r e ( ' i n t e r n a l / u r l ' ) ;   
 c o n s t   v m   =   r e q u i r e ( ' v m ' ) ;   
 c o n s t   a s s e r t   =   r e q u i r e ( ' a s s e r t ' ) . o k ;   
 c o n s t   f s   =   r e q u i r e ( ' f s ' ) ;   
 c o n s t   i n t e r n a l F S   =   r e q u i r e ( ' i n t e r n a l / f s ' ) ;   
 c o n s t   p a t h   =   r e q u i r e ( ' p a t h ' ) ;   
 c o n s t   {   
     i n t e r n a l M o d u l e R e a d F i l e ,   
     i n t e r n a l M o d u l e S t a t   
 }   =   p r o c e s s . b i n d i n g ( ' f s ' ) ;   
 / *   S y N o d e     
 c o n s t   p r e s e r v e S y m l i n k s   =   ! ! p r o c e s s . b i n d i n g ( ' c o n f i g ' ) . p r e s e r v e S y m l i n k s ;   
 c o n s t   e x p e r i m e n t a l M o d u l e s   =   ! ! p r o c e s s . b i n d i n g ( ' c o n f i g ' ) . e x p e r i m e n t a l M o d u l e s ;   
   
 c o n s t   e r r o r s   =   r e q u i r e ( ' i n t e r n a l / e r r o r s ' ) ;   
   
 c o n s t   L o a d e r   =   r e q u i r e ( ' i n t e r n a l / l o a d e r / L o a d e r ' ) ;   
 c o n s t   M o d u l e J o b   =   r e q u i r e ( ' i n t e r n a l / l o a d e r / M o d u l e J o b ' ) ;   
 c o n s t   {   c r e a t e D y n a m i c M o d u l e   }   =   r e q u i r e ( ' i n t e r n a l / l o a d e r / M o d u l e W r a p ' ) ;   
 * /   
 c o n s t   p r e s e r v e S y m l i n k s   =   f a l s e ;   
 c o n s t   e x p e r i m e n t a l M o d u l e s   =   f a l s e ;   
 c o n s t   e r r o r s   =   r e q u i r e ( ' i n t e r n a l / e r r o r s ' ) ;   
 / / e n d   S y N o d e   
 l e t   E S M L o a d e r ;   
   
 f u n c t i o n   s t a t ( f i l e n a m e )   {   
     f i l e n a m e   =   p a t h . _ m a k e L o n g ( f i l e n a m e ) ;   
     c o n s t   c a c h e   =   s t a t . c a c h e ;   
     i f   ( c a c h e   ! = =   n u l l )   {   
         c o n s t   r e s u l t   =   c a c h e . g e t ( f i l e n a m e ) ;   
         i f   ( r e s u l t   ! = =   u n d e f i n e d )   r e t u r n   r e s u l t ;   
     }   
     c o n s t   r e s u l t   =   i n t e r n a l M o d u l e S t a t ( f i l e n a m e ) ;   
     i f   ( c a c h e   ! = =   n u l l )   c a c h e . s e t ( f i l e n a m e ,   r e s u l t ) ;   
     r e t u r n   r e s u l t ;   
 }   
 s t a t . c a c h e   =   n u l l ;   
   
 f u n c t i o n   u p d a t e C h i l d r e n ( p a r e n t ,   c h i l d ,   s c a n )   {   
     v a r   c h i l d r e n   =   p a r e n t   & &   p a r e n t . c h i l d r e n ;   
     i f   ( c h i l d r e n   & &   ! ( s c a n   & &   c h i l d r e n . i n c l u d e s ( c h i l d ) ) )   
         c h i l d r e n . p u s h ( c h i l d ) ;   
 }   
   
 f u n c t i o n   M o d u l e ( i d ,   p a r e n t )   {   
     t h i s . i d   =   i d ;   
     t h i s . e x p o r t s   =   { } ;   
     t h i s . p a r e n t   =   p a r e n t ;   
     u p d a t e C h i l d r e n ( p a r e n t ,   t h i s ,   f a l s e ) ;   
     t h i s . f i l e n a m e   =   n u l l ;   
     t h i s . l o a d e d   =   f a l s e ;   
     t h i s . c h i l d r e n   =   [ ] ;   
 }   
 m o d u l e . e x p o r t s   =   M o d u l e ;   
   
 M o d u l e . _ c a c h e   =   O b j e c t . c r e a t e ( n u l l ) ;   
 M o d u l e . _ p a t h C a c h e   =   O b j e c t . c r e a t e ( n u l l ) ;   
 M o d u l e . _ e x t e n s i o n s   =   O b j e c t . c r e a t e ( n u l l ) ;   
 v a r   m o d u l e P a t h s   =   [ ] ;   
 M o d u l e . g l o b a l P a t h s   =   [ ] ;   
   
 M o d u l e . w r a p p e r   =   N a t i v e M o d u l e . w r a p p e r ;   
 M o d u l e . w r a p   =   N a t i v e M o d u l e . w r a p ;   
 M o d u l e . _ d e b u g   =   u t i l . d e b u g l o g ( ' m o d u l e ' ) ;   
   
 / /   W e   u s e   t h i s   a l i a s   f o r   t h e   p r e p r o c e s s o r   t h a t   f i l t e r s   i t   o u t   
 c o n s t   d e b u g   =   M o d u l e . _ d e b u g ;   
   
   
 / /   g i v e n   a   m o d u l e   n a m e ,   a n d   a   l i s t   o f   p a t h s   t o   t e s t ,   r e t u r n s   t h e   f i r s t   
 / /   m a t c h i n g   f i l e   i n   t h e   f o l l o w i n g   p r e c e d e n c e .   
 / /   
 / /   r e q u i r e ( " a . < e x t > " )   
 / /       - >   a . < e x t >   
 / /   
 / /   r e q u i r e ( " a " )   
 / /       - >   a   
 / /       - >   a . < e x t >   
 / /       - >   a / i n d e x . < e x t >   
   
 / /   c h e c k   i f   t h e   d i r e c t o r y   i s   a   p a c k a g e . j s o n   d i r   
 c o n s t   p a c k a g e M a i n C a c h e   =   O b j e c t . c r e a t e ( n u l l ) ;   
   
 f u n c t i o n   r e a d P a c k a g e ( r e q u e s t P a t h )   {   
     c o n s t   e n t r y   =   p a c k a g e M a i n C a c h e [ r e q u e s t P a t h ] ;   
     i f   ( e n t r y )   
         r e t u r n   e n t r y ;   
   
     c o n s t   j s o n P a t h   =   p a t h . r e s o l v e ( r e q u e s t P a t h ,   ' p a c k a g e . j s o n ' ) ;   
     c o n s t   j s o n   =   i n t e r n a l M o d u l e R e a d F i l e ( p a t h . _ m a k e L o n g ( j s o n P a t h ) ) ;   
   
     i f   ( j s o n   = = =   u n d e f i n e d )   {   
         r e t u r n   f a l s e ;   
     }   
   
     t r y   {   
         v a r   p k g   =   p a c k a g e M a i n C a c h e [ r e q u e s t P a t h ]   =   J S O N . p a r s e ( j s o n ) . m a i n ;   
     }   c a t c h   ( e )   {   
         e . p a t h   =   j s o n P a t h ;   
         e . m e s s a g e   =   ' E r r o r   p a r s i n g   '   +   j s o n P a t h   +   ' :   '   +   e . m e s s a g e ;   
         t h r o w   e ;   
     }   
     r e t u r n   p k g ;   
 }   
   
 f u n c t i o n   t r y P a c k a g e ( r e q u e s t P a t h ,   e x t s ,   i s M a i n )   {   
     v a r   p k g   =   r e a d P a c k a g e ( r e q u e s t P a t h ) ;   
   
     i f   ( ! p k g )   r e t u r n   f a l s e ;   
   
     v a r   f i l e n a m e   =   p a t h . r e s o l v e ( r e q u e s t P a t h ,   p k g ) ;   
     r e t u r n   t r y F i l e ( f i l e n a m e ,   i s M a i n )   | |   
                   t r y E x t e n s i o n s ( f i l e n a m e ,   e x t s ,   i s M a i n )   | |   
                   t r y E x t e n s i o n s ( p a t h . r e s o l v e ( f i l e n a m e ,   ' i n d e x ' ) ,   e x t s ,   i s M a i n ) ;   
 }   
   
 / /   I n   o r d e r   t o   m i n i m i z e   u n n e c e s s a r y   l s t a t ( )   c a l l s ,   
 / /   t h i s   c a c h e   i s   a   l i s t   o f   k n o w n - r e a l   p a t h s .   
 / /   S e t   t o   a n   e m p t y   M a p   t o   r e s e t .   
 c o n s t   r e a l p a t h C a c h e   =   n e w   M a p ( ) ;   
   
 / /   c h e c k   i f   t h e   f i l e   e x i s t s   a n d   i s   n o t   a   d i r e c t o r y   
 / /   i f   u s i n g   - - p r e s e r v e - s y m l i n k s   a n d   i s M a i n   i s   f a l s e ,   
 / /   k e e p   s y m l i n k s   i n t a c t ,   o t h e r w i s e   r e s o l v e   t o   t h e   
 / /   a b s o l u t e   r e a l p a t h .   
 f u n c t i o n   t r y F i l e ( r e q u e s t P a t h ,   i s M a i n )   {   
     c o n s t   r c   =   s t a t ( r e q u e s t P a t h ) ;   
     i f   ( p r e s e r v e S y m l i n k s   & &   ! i s M a i n )   {   
         r e t u r n   r c   = = =   0   & &   p a t h . r e s o l v e ( r e q u e s t P a t h ) ;   
     }   
     r e t u r n   r c   = = =   0   & &   t o R e a l P a t h ( r e q u e s t P a t h ) ;   
 }   
   
 f u n c t i o n   t o R e a l P a t h ( r e q u e s t P a t h )   {   
     r e t u r n   f s . r e a l p a t h S y n c ( r e q u e s t P a t h ,   {   
         [ i n t e r n a l F S . r e a l p a t h C a c h e K e y ] :   r e a l p a t h C a c h e   
     } ) ;   
 }   
   
 / /   g i v e n   a   p a t h ,   c h e c k   i f   t h e   f i l e   e x i s t s   w i t h   a n y   o f   t h e   s e t   e x t e n s i o n s   
 f u n c t i o n   t r y E x t e n s i o n s ( p ,   e x t s ,   i s M a i n )   {   
     f o r   ( v a r   i   =   0 ;   i   <   e x t s . l e n g t h ;   i + + )   {   
         c o n s t   f i l e n a m e   =   t r y F i l e ( p   +   e x t s [ i ] ,   i s M a i n ) ;   
   
         i f   ( f i l e n a m e )   {   
             r e t u r n   f i l e n a m e ;   
         }   
     }   
     r e t u r n   f a l s e ;   
 }   
   
 v a r   w a r n e d   =   f a l s e ;   
 M o d u l e . _ f i n d P a t h   =   f u n c t i o n ( r e q u e s t ,   p a t h s ,   i s M a i n )   {   
     i f   ( p a t h . i s A b s o l u t e ( r e q u e s t ) )   {   
         p a t h s   =   [ ' ' ] ;   
     }   e l s e   i f   ( ! p a t h s   | |   p a t h s . l e n g t h   = = =   0 )   {   
         r e t u r n   f a l s e ;   
     }   
   
     v a r   c a c h e K e y   =   r e q u e s t   +   ' \ x 0 0 '   +   
                                 ( p a t h s . l e n g t h   = = =   1   ?   p a t h s [ 0 ]   :   p a t h s . j o i n ( ' \ x 0 0 ' ) ) ;   
     v a r   e n t r y   =   M o d u l e . _ p a t h C a c h e [ c a c h e K e y ] ;   
     i f   ( e n t r y )   
         r e t u r n   e n t r y ;   
   
     v a r   e x t s ;   
     v a r   t r a i l i n g S l a s h   =   r e q u e s t . l e n g t h   >   0   & &   
                                             r e q u e s t . c h a r C o d e A t ( r e q u e s t . l e n g t h   -   1 )   = = =   4 7 / * / * / ;   
   
     / /   F o r   e a c h   p a t h   
     f o r   ( v a r   i   =   0 ;   i   <   p a t h s . l e n g t h ;   i + + )   {   
         / /   D o n ' t   s e a r c h   f u r t h e r   i f   p a t h   d o e s n ' t   e x i s t   
         c o n s t   c u r P a t h   =   p a t h s [ i ] ;   
         i f   ( c u r P a t h   & &   s t a t ( c u r P a t h )   <   1 )   c o n t i n u e ;   
         v a r   b a s e P a t h   =   p a t h . r e s o l v e ( c u r P a t h ,   r e q u e s t ) ;   
         v a r   f i l e n a m e ;   
   
         v a r   r c   =   s t a t ( b a s e P a t h ) ;   
         i f   ( ! t r a i l i n g S l a s h )   {   
             i f   ( r c   = = =   0 )   {     / /   F i l e .   
                 i f   ( p r e s e r v e S y m l i n k s   & &   ! i s M a i n )   {   
                     f i l e n a m e   =   p a t h . r e s o l v e ( b a s e P a t h ) ;   
                 }   e l s e   {   
                     f i l e n a m e   =   t o R e a l P a t h ( b a s e P a t h ) ;   
                 }   
             }   e l s e   i f   ( r c   = = =   1 )   {     / /   D i r e c t o r y .   
                 i f   ( e x t s   = = =   u n d e f i n e d )   
                     e x t s   =   O b j e c t . k e y s ( M o d u l e . _ e x t e n s i o n s ) ;   
                 f i l e n a m e   =   t r y P a c k a g e ( b a s e P a t h ,   e x t s ,   i s M a i n ) ;   
             }   
   
             i f   ( ! f i l e n a m e )   {   
                 / /   t r y   i t   w i t h   e a c h   o f   t h e   e x t e n s i o n s   
                 i f   ( e x t s   = = =   u n d e f i n e d )   
                     e x t s   =   O b j e c t . k e y s ( M o d u l e . _ e x t e n s i o n s ) ;   
                 f i l e n a m e   =   t r y E x t e n s i o n s ( b a s e P a t h ,   e x t s ,   i s M a i n ) ;   
             }   
         }   
   
         i f   ( ! f i l e n a m e   & &   r c   = = =   1 )   {     / /   D i r e c t o r y .   
             i f   ( e x t s   = = =   u n d e f i n e d )   
                 e x t s   =   O b j e c t . k e y s ( M o d u l e . _ e x t e n s i o n s ) ;   
             f i l e n a m e   =   t r y P a c k a g e ( b a s e P a t h ,   e x t s ,   i s M a i n )   | |   
                 / /   t r y   i t   w i t h   e a c h   o f   t h e   e x t e n s i o n s   a t   " i n d e x "   
                 t r y E x t e n s i o n s ( p a t h . r e s o l v e ( b a s e P a t h ,   ' i n d e x ' ) ,   e x t s ,   i s M a i n ) ;   
         }   
   
         i f   ( f i l e n a m e )   {   
             / /   W a r n   o n c e   i f   ' . '   r e s o l v e d   o u t s i d e   t h e   m o d u l e   d i r   
             i f   ( r e q u e s t   = = =   ' . '   & &   i   >   0 )   {   
                 i f   ( ! w a r n e d )   {   
                     w a r n e d   =   t r u e ;   
                     p r o c e s s . e m i t W a r n i n g (   
                         ' w a r n i n g :   r e q u i r e ( \ ' . \ ' )   r e s o l v e d   o u t s i d e   t h e   p a c k a g e   '   +   
                         ' d i r e c t o r y .   T h i s   f u n c t i o n a l i t y   i s   d e p r e c a t e d   a n d   w i l l   b e   r e m o v e d   '   +   
                         ' s o o n . ' ,   
                         ' D e p r e c a t i o n W a r n i n g ' ,   ' D E P 0 0 1 9 ' ) ;   
                 }   
             }   
   
             M o d u l e . _ p a t h C a c h e [ c a c h e K e y ]   =   f i l e n a m e ;   
             r e t u r n   f i l e n a m e ;   
         }   
     }   
     r e t u r n   f a l s e ;   
 } ;   
   
 / /   ' n o d e _ m o d u l e s '   c h a r a c t e r   c o d e s   r e v e r s e d   
 v a r   n m C h a r s   =   [   1 1 5 ,   1 0 1 ,   1 0 8 ,   1 1 7 ,   1 0 0 ,   1 1 1 ,   1 0 9 ,   9 5 ,   1 0 1 ,   1 0 0 ,   1 1 1 ,   1 1 0   ] ;   
 v a r   n m L e n   =   n m C h a r s . l e n g t h ;   
 i f   ( p r o c e s s . p l a t f o r m   = = =   ' w i n 3 2 ' )   {   
     / /   ' f r o m '   i s   t h e   _ _ d i r n a m e   o f   t h e   m o d u l e .   
     M o d u l e . _ n o d e M o d u l e P a t h s   =   f u n c t i o n ( f r o m )   {   
         / /   g u a r a n t e e   t h a t   ' f r o m '   i s   a b s o l u t e .   
         f r o m   =   p a t h . r e s o l v e ( f r o m ) ;   
   
         / /   n o t e :   t h i s   a p p r o a c h   * o n l y *   w o r k s   w h e n   t h e   p a t h   i s   g u a r a n t e e d   
         / /   t o   b e   a b s o l u t e .     D o i n g   a   f u l l y - e d g e - c a s e - c o r r e c t   p a t h . s p l i t   
         / /   t h a t   w o r k s   o n   b o t h   W i n d o w s   a n d   P o s i x   i s   n o n - t r i v i a l .   
   
         / /   r e t u r n   r o o t   n o d e _ m o d u l e s   w h e n   p a t h   i s   ' D : \ \ ' .   
         / /   p a t h . r e s o l v e   w i l l   m a k e   s u r e   f r o m . l e n g t h   > = 3   i n   W i n d o w s .   
         i f   ( f r o m . c h a r C o d e A t ( f r o m . l e n g t h   -   1 )   = = =   9 2 / * \ * /   & &   
                 f r o m . c h a r C o d e A t ( f r o m . l e n g t h   -   2 )   = = =   5 8 / * : * / )   
             r e t u r n   [ f r o m   +   ' n o d e _ m o d u l e s ' ] ;   
   
         c o n s t   p a t h s   =   [ ] ;   
         v a r   p   =   0 ;   
         v a r   l a s t   =   f r o m . l e n g t h ;   
         f o r   ( v a r   i   =   f r o m . l e n g t h   -   1 ;   i   > =   0 ;   - - i )   {   
             c o n s t   c o d e   =   f r o m . c h a r C o d e A t ( i ) ;   
             / /   T h e   p a t h   s e g m e n t   s e p a r a t o r   c h e c k   ( ' \ '   a n d   ' / ' )   w a s   u s e d   t o   g e t   
             / /   n o d e _ m o d u l e s   p a t h   f o r   e v e r y   p a t h   s e g m e n t .   
             / /   U s e   c o l o n   a s   a n   e x t r a   c o n d i t i o n   s i n c e   w e   c a n   g e t   n o d e _ m o d u l e s   
             / /   p a t h   f o r   d r i v e   r o o t   l i k e   ' C : \ n o d e _ m o d u l e s '   a n d   d o n ' t   n e e d   t o   
             / /   p a r s e   d r i v e   n a m e .   
             i f   ( c o d e   = = =   9 2 / * \ * /   | |   c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   5 8 / * : * / )   {   
                 i f   ( p   ! = =   n m L e n )   
                     p a t h s . p u s h ( f r o m . s l i c e ( 0 ,   l a s t )   +   ' \ \ n o d e _ m o d u l e s ' ) ;   
                 l a s t   =   i ;   
                 p   =   0 ;   
             }   e l s e   i f   ( p   ! = =   - 1 )   {   
                 i f   ( n m C h a r s [ p ]   = = =   c o d e )   {   
                     + + p ;   
                 }   e l s e   {   
                     p   =   - 1 ;   
                 }   
             }   
         }   
   
         r e t u r n   p a t h s ;   
     } ;   
 }   e l s e   {   / /   p o s i x   
     / /   ' f r o m '   i s   t h e   _ _ d i r n a m e   o f   t h e   m o d u l e .   
     M o d u l e . _ n o d e M o d u l e P a t h s   =   f u n c t i o n ( f r o m )   {   
         / /   g u a r a n t e e   t h a t   ' f r o m '   i s   a b s o l u t e .   
         f r o m   =   p a t h . r e s o l v e ( f r o m ) ;   
         / /   R e t u r n   e a r l y   n o t   o n l y   t o   a v o i d   u n n e c e s s a r y   w o r k ,   b u t   t o   * a v o i d *   r e t u r n i n g   
         / /   a n   a r r a y   o f   t w o   i t e m s   f o r   a   r o o t :   [   ' / / n o d e _ m o d u l e s ' ,   ' / n o d e _ m o d u l e s '   ]   
         i f   ( f r o m   = = =   ' / ' )   
             r e t u r n   [ ' / n o d e _ m o d u l e s ' ] ;   
   
         / /   n o t e :   t h i s   a p p r o a c h   * o n l y *   w o r k s   w h e n   t h e   p a t h   i s   g u a r a n t e e d   
         / /   t o   b e   a b s o l u t e .     D o i n g   a   f u l l y - e d g e - c a s e - c o r r e c t   p a t h . s p l i t   
         / /   t h a t   w o r k s   o n   b o t h   W i n d o w s   a n d   P o s i x   i s   n o n - t r i v i a l .   
         c o n s t   p a t h s   =   [ ] ;   
         v a r   p   =   0 ;   
         v a r   l a s t   =   f r o m . l e n g t h ;   
         f o r   ( v a r   i   =   f r o m . l e n g t h   -   1 ;   i   > =   0 ;   - - i )   {   
             c o n s t   c o d e   =   f r o m . c h a r C o d e A t ( i ) ;   
             i f   ( c o d e   = = =   4 7 / * / * / )   {   
                 i f   ( p   ! = =   n m L e n )   
                     p a t h s . p u s h ( f r o m . s l i c e ( 0 ,   l a s t )   +   ' / n o d e _ m o d u l e s ' ) ;   
                 l a s t   =   i ;   
                 p   =   0 ;   
             }   e l s e   i f   ( p   ! = =   - 1 )   {   
                 i f   ( n m C h a r s [ p ]   = = =   c o d e )   {   
                     + + p ;   
                 }   e l s e   {   
                     p   =   - 1 ;   
                 }   
             }   
         }   
   
         / /   A p p e n d   / n o d e _ m o d u l e s   t o   h a n d l e   r o o t   p a t h s .   
         p a t h s . p u s h ( ' / n o d e _ m o d u l e s ' ) ;   
   
         r e t u r n   p a t h s ;   
     } ;   
 }   
   
   
 / /   ' i n d e x . '   c h a r a c t e r   c o d e s   
 v a r   i n d e x C h a r s   =   [   1 0 5 ,   1 1 0 ,   1 0 0 ,   1 0 1 ,   1 2 0 ,   4 6   ] ;   
 v a r   i n d e x L e n   =   i n d e x C h a r s . l e n g t h ;   
 M o d u l e . _ r e s o l v e L o o k u p P a t h s   =   f u n c t i o n ( r e q u e s t ,   p a r e n t ,   n e w R e t u r n )   {   
     i f   ( N a t i v e M o d u l e . n o n I n t e r n a l E x i s t s ( r e q u e s t ) )   {   
         d e b u g ( ' l o o k i n g   f o r   % j   i n   [ ] ' ,   r e q u e s t ) ;   
         r e t u r n   ( n e w R e t u r n   ?   n u l l   :   [ r e q u e s t ,   [ ] ] ) ;   
     }   
   
     / /   C h e c k   f o r   r e l a t i v e   p a t h   
     i f   ( r e q u e s t . l e n g t h   <   2   | |   
             r e q u e s t . c h a r C o d e A t ( 0 )   ! = =   4 6 / * . * /   | |   
             ( r e q u e s t . c h a r C o d e A t ( 1 )   ! = =   4 6 / * . * /   & &   
               r e q u e s t . c h a r C o d e A t ( 1 )   ! = =   4 7 / * / * / ) )   {   
         v a r   p a t h s   =   m o d u l e P a t h s ;   
         i f   ( p a r e n t )   {   
             i f   ( ! p a r e n t . p a t h s )   
                 p a t h s   =   p a r e n t . p a t h s   =   [ ] ;   
             e l s e   
                 p a t h s   =   p a r e n t . p a t h s . c o n c a t ( p a t h s ) ;   
         }   
   
         / /   M a i n t a i n   b a c k w a r d s   c o m p a t   w i t h   c e r t a i n   b r o k e n   u s e s   o f   r e q u i r e ( ' . ' )   
         / /   b y   p u t t i n g   t h e   m o d u l e ' s   d i r e c t o r y   i n   f r o n t   o f   t h e   l o o k u p   p a t h s .   
         i f   ( r e q u e s t   = = =   ' . ' )   {   
             i f   ( p a r e n t   & &   p a r e n t . f i l e n a m e )   {   
                 p a t h s . u n s h i f t ( p a t h . d i r n a m e ( p a r e n t . f i l e n a m e ) ) ;   
             }   e l s e   {   
                 p a t h s . u n s h i f t ( p a t h . r e s o l v e ( r e q u e s t ) ) ;   
             }   
         }   
   
         d e b u g ( ' l o o k i n g   f o r   % j   i n   % j ' ,   r e q u e s t ,   p a t h s ) ;   
         r e t u r n   ( n e w R e t u r n   ?   ( p a t h s . l e n g t h   >   0   ?   p a t h s   :   n u l l )   :   [ r e q u e s t ,   p a t h s ] ) ;   
     }   
   
     / /   w i t h   - - e v a l ,   p a r e n t . i d   i s   n o t   s e t   a n d   p a r e n t . f i l e n a m e   i s   n u l l   
     i f   ( ! p a r e n t   | |   ! p a r e n t . i d   | |   ! p a r e n t . f i l e n a m e )   {   
         / /   m a k e   r e q u i r e ( ' . / p a t h / t o / f o o ' )   w o r k   -   n o r m a l l y   t h e   p a t h   i s   t a k e n   
         / /   f r o m   r e a l p a t h ( _ _ f i l e n a m e )   b u t   w i t h   e v a l   t h e r e   i s   n o   f i l e n a m e   
         v a r   m a i n P a t h s   =   [ ' . ' ] . c o n c a t ( M o d u l e . _ n o d e M o d u l e P a t h s ( ' . ' ) ,   m o d u l e P a t h s ) ;   
   
         d e b u g ( ' l o o k i n g   f o r   % j   i n   % j ' ,   r e q u e s t ,   m a i n P a t h s ) ;   
         r e t u r n   ( n e w R e t u r n   ?   m a i n P a t h s   :   [ r e q u e s t ,   m a i n P a t h s ] ) ;   
     }   
   
     / /   I s   t h e   p a r e n t   a n   i n d e x   m o d u l e ?   
     / /   W e   c a n   a s s u m e   t h e   p a r e n t   h a s   a   v a l i d   e x t e n s i o n ,   
     / /   a s   i t   a l r e a d y   h a s   b e e n   a c c e p t e d   a s   a   m o d u l e .   
     c o n s t   b a s e   =   p a t h . b a s e n a m e ( p a r e n t . f i l e n a m e ) ;   
     v a r   p a r e n t I d P a t h ;   
     i f   ( b a s e . l e n g t h   >   i n d e x L e n )   {   
         v a r   i   =   0 ;   
         f o r   ( ;   i   <   i n d e x L e n ;   + + i )   {   
             i f   ( i n d e x C h a r s [ i ]   ! = =   b a s e . c h a r C o d e A t ( i ) )   
                 b r e a k ;   
         }   
         i f   ( i   = = =   i n d e x L e n )   {   
             / /   W e   m a t c h e d   ' i n d e x . ' ,   l e t ' s   v a l i d a t e   t h e   r e s t   
             f o r   ( ;   i   <   b a s e . l e n g t h ;   + + i )   {   
                 c o n s t   c o d e   =   b a s e . c h a r C o d e A t ( i ) ;   
                 i f   ( c o d e   ! = =   9 5 / * _ * /   & &   
                         ( c o d e   <   4 8 / * 0 * /   | |   c o d e   >   5 7 / * 9 * / )   & &   
                         ( c o d e   <   6 5 / * A * /   | |   c o d e   >   9 0 / * Z * / )   & &   
                         ( c o d e   <   9 7 / * a * /   | |   c o d e   >   1 2 2 / * z * / ) )   
                     b r e a k ;   
             }   
             i f   ( i   = = =   b a s e . l e n g t h )   {   
                 / /   I s   a n   i n d e x   m o d u l e   
                 p a r e n t I d P a t h   =   p a r e n t . i d ;   
             }   e l s e   {   
                 / /   N o t   a n   i n d e x   m o d u l e   
                 p a r e n t I d P a t h   =   p a t h . d i r n a m e ( p a r e n t . i d ) ;   
             }   
         }   e l s e   {   
             / /   N o t   a n   i n d e x   m o d u l e   
             p a r e n t I d P a t h   =   p a t h . d i r n a m e ( p a r e n t . i d ) ;   
         }   
     }   e l s e   {   
         / /   N o t   a n   i n d e x   m o d u l e   
         p a r e n t I d P a t h   =   p a t h . d i r n a m e ( p a r e n t . i d ) ;   
     }   
     v a r   i d   =   p a t h . r e s o l v e ( p a r e n t I d P a t h ,   r e q u e s t ) ;   
   
     / /   m a k e   s u r e   r e q u i r e ( ' . / p a t h ' )   a n d   r e q u i r e ( ' p a t h ' )   g e t   d i s t i n c t   i d s ,   e v e n   
     / /   w h e n   c a l l e d   f r o m   t h e   t o p l e v e l   j s   f i l e   
     i f   ( p a r e n t I d P a t h   = = =   ' . '   & &   i d . i n d e x O f ( ' / ' )   = = =   - 1 )   {   
         i d   =   ' . / '   +   i d ;   
     }   
   
     d e b u g ( ' R E L A T I V E :   r e q u e s t e d :   % s   s e t   I D   t o :   % s   f r o m   % s ' ,   r e q u e s t ,   i d ,   
                 p a r e n t . i d ) ;   
   
     v a r   p a r e n t D i r   =   [ p a t h . d i r n a m e ( p a r e n t . f i l e n a m e ) ] ;   
     d e b u g ( ' l o o k i n g   f o r   % j   i n   % j ' ,   i d ,   p a r e n t D i r ) ;   
     r e t u r n   ( n e w R e t u r n   ?   p a r e n t D i r   :   [ i d ,   p a r e n t D i r ] ) ;   
 } ;   
   
   
 / /   C h e c k   t h e   c a c h e   f o r   t h e   r e q u e s t e d   f i l e .   
 / /   1 .   I f   a   m o d u l e   a l r e a d y   e x i s t s   i n   t h e   c a c h e :   r e t u r n   i t s   e x p o r t s   o b j e c t .   
 / /   2 .   I f   t h e   m o d u l e   i s   n a t i v e :   c a l l   ` N a t i v e M o d u l e . r e q u i r e ( ) `   w i t h   t h e   
 / /         f i l e n a m e   a n d   r e t u r n   t h e   r e s u l t .   
 / /   3 .   O t h e r w i s e ,   c r e a t e   a   n e w   m o d u l e   f o r   t h e   f i l e   a n d   s a v e   i t   t o   t h e   c a c h e .   
 / /         T h e n   h a v e   i t   l o a d     t h e   f i l e   c o n t e n t s   b e f o r e   r e t u r n i n g   i t s   e x p o r t s   
 / /         o b j e c t .   
 M o d u l e . _ l o a d   =   f u n c t i o n ( r e q u e s t ,   p a r e n t ,   i s M a i n )   {   
     i f   ( p a r e n t )   {   
         d e b u g ( ' M o d u l e . _ l o a d   R E Q U E S T   % s   p a r e n t :   % s ' ,   r e q u e s t ,   p a r e n t . i d ) ;   
     }   
   
     i f   ( i s M a i n   & &   e x p e r i m e n t a l M o d u l e s )   {   
         ( a s y n c   ( )   = >   {   
             / /   l o a d e r   s e t u p   
             i f   ( ! E S M L o a d e r )   {   
                 E S M L o a d e r   =   n e w   L o a d e r ( ) ;   
                 c o n s t   u s e r L o a d e r   =   f a l s e   / /   S y N o d e   p r o c e s s . b i n d i n g ( ' c o n f i g ' ) . u s e r L o a d e r ;   
                 i f   ( u s e r L o a d e r )   {   
                     c o n s t   h o o k s   =   a w a i t   E S M L o a d e r . i m p o r t ( u s e r L o a d e r ) ;   
                     E S M L o a d e r   =   n e w   L o a d e r ( ) ;   
                     E S M L o a d e r . h o o k ( h o o k s ) ;   
                 }   
             }   
             a w a i t   E S M L o a d e r . i m p o r t ( g e t U R L F r o m F i l e P a t h ( r e q u e s t ) . p a t h n a m e ) ;   
         } ) ( )   
         . c a t c h ( ( e )   = >   {   
             c o n s o l e . e r r o r ( e ) ;   
             p r o c e s s . e x i t ( 1 ) ;   
         } ) ;   
         r e t u r n ;   
     }   
   
     v a r   f i l e n a m e   =   M o d u l e . _ r e s o l v e F i l e n a m e ( r e q u e s t ,   p a r e n t ,   i s M a i n ) ;   
   
     v a r   c a c h e d M o d u l e   =   M o d u l e . _ c a c h e [ f i l e n a m e ] ;   
     i f   ( c a c h e d M o d u l e )   {   
         u p d a t e C h i l d r e n ( p a r e n t ,   c a c h e d M o d u l e ,   t r u e ) ;   
         r e t u r n   c a c h e d M o d u l e . e x p o r t s ;   
     }   
   
     i f   ( N a t i v e M o d u l e . n o n I n t e r n a l E x i s t s ( f i l e n a m e ) )   {   
         d e b u g ( ' l o a d   n a t i v e   m o d u l e   % s ' ,   r e q u e s t ) ;   
         r e t u r n   N a t i v e M o d u l e . r e q u i r e ( f i l e n a m e ) ;   
     }   
   
     / /   D o n ' t   c a l l   u p d a t e C h i l d r e n ( ) ,   M o d u l e   c o n s t r u c t o r   a l r e a d y   d o e s .   
     v a r   m o d u l e   =   n e w   M o d u l e ( f i l e n a m e ,   p a r e n t ) ;   
   
     i f   ( i s M a i n )   {   
         p r o c e s s . m a i n M o d u l e   =   m o d u l e ;   
         m o d u l e . i d   =   ' . ' ;   
     }   
   
     M o d u l e . _ c a c h e [ f i l e n a m e ]   =   m o d u l e ;   
   
     t r y M o d u l e L o a d ( m o d u l e ,   f i l e n a m e ) ;   
   
     r e t u r n   m o d u l e . e x p o r t s ;   
 } ;   
   
 f u n c t i o n   t r y M o d u l e L o a d ( m o d u l e ,   f i l e n a m e )   {   
     v a r   t h r e w   =   t r u e ;   
     t r y   {   
         m o d u l e . l o a d ( f i l e n a m e ) ;   
         t h r e w   =   f a l s e ;   
     }   f i n a l l y   {   
         i f   ( t h r e w )   {   
             d e l e t e   M o d u l e . _ c a c h e [ f i l e n a m e ] ;   
         }   
     }   
 }   
   
 M o d u l e . _ r e s o l v e F i l e n a m e   =   f u n c t i o n ( r e q u e s t ,   p a r e n t ,   i s M a i n ,   o p t i o n s )   {   
     i f   ( N a t i v e M o d u l e . n o n I n t e r n a l E x i s t s ( r e q u e s t ) )   {   
         r e t u r n   r e q u e s t ;   
     }   
   
     v a r   p a t h s ;   
   
     i f   ( t y p e o f   o p t i o n s   = = =   ' o b j e c t '   & &   o p t i o n s   ! = =   n u l l   & &   
             A r r a y . i s A r r a y ( o p t i o n s . p a t h s ) )   {   
         p a t h s   =   [ ] ;   
   
         f o r   ( v a r   i   =   0 ;   i   <   o p t i o n s . p a t h s . l e n g t h ;   i + + )   {   
             c o n s t   p a t h   =   o p t i o n s . p a t h s [ i ] ;   
             c o n s t   l o o k u p P a t h s   =   M o d u l e . _ r e s o l v e L o o k u p P a t h s ( p a t h ,   p a r e n t ,   t r u e ) ;   
   
             i f   ( ! p a t h s . i n c l u d e s ( p a t h ) )   
                 p a t h s . p u s h ( p a t h ) ;   
   
             f o r   ( v a r   j   =   0 ;   j   <   l o o k u p P a t h s . l e n g t h ;   j + + )   {   
                 i f   ( ! p a t h s . i n c l u d e s ( l o o k u p P a t h s [ j ] ) )   
                     p a t h s . p u s h ( l o o k u p P a t h s [ j ] ) ;   
             }   
         }   
     }   e l s e   {   
         p a t h s   =   M o d u l e . _ r e s o l v e L o o k u p P a t h s ( r e q u e s t ,   p a r e n t ,   t r u e ) ;   
     }   
   
     / /   l o o k   u p   t h e   f i l e n a m e   f i r s t ,   s i n c e   t h a t ' s   t h e   c a c h e   k e y .   
     v a r   f i l e n a m e   =   M o d u l e . _ f i n d P a t h ( r e q u e s t ,   p a t h s ,   i s M a i n ) ;   
     i f   ( ! f i l e n a m e )   {   
         v a r   e r r   =   n e w   E r r o r ( ` C a n n o t   f i n d   m o d u l e   ' $ { r e q u e s t } ' ` ) ;   
         e r r . c o d e   =   ' M O D U L E _ N O T _ F O U N D ' ;   
         t h r o w   e r r ;   
     }   
     r e t u r n   f i l e n a m e ;   
 } ;   
   
   
 / /   G i v e n   a   f i l e   n a m e ,   p a s s   i t   t o   t h e   p r o p e r   e x t e n s i o n   h a n d l e r .   
 M o d u l e . p r o t o t y p e . l o a d   =   f u n c t i o n ( f i l e n a m e )   {   
     d e b u g ( ' l o a d   % j   f o r   m o d u l e   % j ' ,   f i l e n a m e ,   t h i s . i d ) ;   
   
     a s s e r t ( ! t h i s . l o a d e d ) ;   
     t h i s . f i l e n a m e   =   f i l e n a m e ;   
     t h i s . p a t h s   =   M o d u l e . _ n o d e M o d u l e P a t h s ( p a t h . d i r n a m e ( f i l e n a m e ) ) ;   
   
     v a r   e x t e n s i o n   =   p a t h . e x t n a m e ( f i l e n a m e )   | |   ' . j s ' ;   
     i f   ( ! M o d u l e . _ e x t e n s i o n s [ e x t e n s i o n ] )   e x t e n s i o n   =   ' . j s ' ;   
     M o d u l e . _ e x t e n s i o n s [ e x t e n s i o n ] ( t h i s ,   f i l e n a m e ) ;   
     t h i s . l o a d e d   =   t r u e ;   
   
     i f   ( E S M L o a d e r )   {   
         c o n s t   u r l   =   g e t U R L F r o m F i l e P a t h ( f i l e n a m e ) ;   
         c o n s t   u r l S t r i n g   =   ` $ { u r l } ` ;   
         i f   ( E S M L o a d e r . m o d u l e M a p . h a s ( u r l S t r i n g )   ! = =   t r u e )   {   
             c o n s t   c t x   =   c r e a t e D y n a m i c M o d u l e ( [ ' d e f a u l t ' ] ,   u r l ) ;   
             c t x . r e f l e c t . e x p o r t s . d e f a u l t . s e t ( t h i s . e x p o r t s ) ;   
             E S M L o a d e r . m o d u l e M a p . s e t ( u r l S t r i n g ,   
                                                             n e w   M o d u l e J o b ( E S M L o a d e r ,   u r l ,   a s y n c   ( )   = >   c t x ) ) ;   
         }   e l s e   {   
             c o n s t   j o b   =   E S M L o a d e r . m o d u l e M a p . g e t ( u r l S t r i n g ) ;   
             i f   ( j o b . r e f l e c t )   
                 j o b . r e f l e c t . e x p o r t s . d e f a u l t . s e t ( t h i s . e x p o r t s ) ;   
         }   
     }   
 } ;   
   
   
 / /   L o a d s   a   m o d u l e   a t   t h e   g i v e n   f i l e   p a t h .   R e t u r n s   t h a t   m o d u l e ' s   
 / /   ` e x p o r t s `   p r o p e r t y .   
 M o d u l e . p r o t o t y p e . r e q u i r e   =   f u n c t i o n ( p a t h )   {   
     a s s e r t ( p a t h ,   ' m i s s i n g   p a t h ' ) ;   
     a s s e r t ( t y p e o f   p a t h   = = =   ' s t r i n g ' ,   ' p a t h   m u s t   b e   a   s t r i n g ' ) ;   
     r e t u r n   M o d u l e . _ l o a d ( p a t h ,   t h i s ,   / *   i s M a i n   * /   f a l s e ) ;   
 } ;   
   
   
 / /   R e s o l v e d   p a t h   t o   p r o c e s s . a r g v [ 1 ]   w i l l   b e   l a z i l y   p l a c e d   h e r e   
 / /   ( n e e d e d   f o r   s e t t i n g   b r e a k p o i n t   w h e n   c a l l e d   w i t h   - - i n s p e c t - b r k )   
 v a r   r e s o l v e d A r g v ;   
   
   
 / /   R u n   t h e   f i l e   c o n t e n t s   i n   t h e   c o r r e c t   s c o p e   o r   s a n d b o x .   E x p o s e   
 / /   t h e   c o r r e c t   h e l p e r   v a r i a b l e s   ( r e q u i r e ,   m o d u l e ,   e x p o r t s )   t o   
 / /   t h e   f i l e .   
 / /   R e t u r n s   e x c e p t i o n ,   i f   a n y .   
 M o d u l e . p r o t o t y p e . _ c o m p i l e   =   f u n c t i o n ( c o n t e n t ,   f i l e n a m e )   {   
   
     c o n t e n t   =   i n t e r n a l M o d u l e . s t r i p S h e b a n g ( c o n t e n t ) ;   
   
     / /   c r e a t e   w r a p p e r   f u n c t i o n   
     v a r   w r a p p e r   =   M o d u l e . w r a p ( c o n t e n t ) ;   
   
     v a r   c o m p i l e d W r a p p e r   =   v m . r u n I n T h i s C o n t e x t ( w r a p p e r ,   {   
         f i l e n a m e :   f i l e n a m e ,   
         l i n e O f f s e t :   0 ,   
         d i s p l a y E r r o r s :   t r u e   
     } ) ;   
   
     v a r   i n s p e c t o r W r a p p e r   =   n u l l ;   
     i f   ( p r o c e s s . _ b r e a k F i r s t L i n e   & &   p r o c e s s . _ e v a l   = =   n u l l )   {   
         i f   ( ! r e s o l v e d A r g v )   {   
             / /   w e   e n t e r   t h e   r e p l   i f   w e ' r e   n o t   g i v e n   a   f i l e n a m e   a r g u m e n t .   
             i f   ( p r o c e s s . a r g v [ 1 ] )   {   
                 r e s o l v e d A r g v   =   M o d u l e . _ r e s o l v e F i l e n a m e ( p r o c e s s . a r g v [ 1 ] ,   n u l l ,   f a l s e ) ;   
             }   e l s e   {   
                 r e s o l v e d A r g v   =   ' r e p l ' ;   
             }   
         }   
   
         / /   S e t   b r e a k p o i n t   o n   m o d u l e   s t a r t   
         i f   ( f i l e n a m e   = = =   r e s o l v e d A r g v )   {   
             d e l e t e   p r o c e s s . _ b r e a k F i r s t L i n e ;   
             i n s p e c t o r W r a p p e r   =   p r o c e s s . b i n d i n g ( ' i n s p e c t o r ' ) . c a l l A n d P a u s e O n S t a r t ;   
             i f   ( ! i n s p e c t o r W r a p p e r )   {   
                 c o n s t   D e b u g   =   v m . r u n I n D e b u g C o n t e x t ( ' D e b u g ' ) ;   
                 D e b u g . s e t B r e a k P o i n t ( c o m p i l e d W r a p p e r ,   0 ,   0 ) ;   
             }   
         }   
     }   
     v a r   d i r n a m e   =   p a t h . d i r n a m e ( f i l e n a m e ) ;   
     v a r   r e q u i r e   =   i n t e r n a l M o d u l e . m a k e R e q u i r e F u n c t i o n ( t h i s ) ;   
     v a r   d e p t h   =   i n t e r n a l M o d u l e . r e q u i r e D e p t h ;   
     i f   ( d e p t h   = = =   0 )   s t a t . c a c h e   =   n e w   M a p ( ) ;   
     v a r   r e s u l t ;   
     i f   ( i n s p e c t o r W r a p p e r )   {   
         r e s u l t   =   i n s p e c t o r W r a p p e r ( c o m p i l e d W r a p p e r ,   t h i s . e x p o r t s ,   t h i s . e x p o r t s ,   
                                                             r e q u i r e ,   t h i s ,   f i l e n a m e ,   d i r n a m e ) ;   
     }   e l s e   {   
         r e s u l t   =   c o m p i l e d W r a p p e r . c a l l ( t h i s . e x p o r t s ,   t h i s . e x p o r t s ,   r e q u i r e ,   t h i s ,   
                                                                     f i l e n a m e ,   d i r n a m e ) ;   
     }   
     i f   ( d e p t h   = = =   0 )   s t a t . c a c h e   =   n u l l ;   
     r e t u r n   r e s u l t ;   
 } ;   
   
   
 / /   N a t i v e   e x t e n s i o n   f o r   . j s   
 M o d u l e . _ e x t e n s i o n s [ ' . j s ' ]   =   f u n c t i o n ( m o d u l e ,   f i l e n a m e )   {   
     v a r   c o n t e n t   =   f s . r e a d F i l e S y n c ( f i l e n a m e ,   ' u t f 8 ' ) ;   
     m o d u l e . _ c o m p i l e ( i n t e r n a l M o d u l e . s t r i p B O M ( c o n t e n t ) ,   f i l e n a m e ) ;   
 } ;   
   
   
 / /   N a t i v e   e x t e n s i o n   f o r   . j s o n   
 M o d u l e . _ e x t e n s i o n s [ ' . j s o n ' ]   =   f u n c t i o n ( m o d u l e ,   f i l e n a m e )   {   
     v a r   c o n t e n t   =   f s . r e a d F i l e S y n c ( f i l e n a m e ,   ' u t f 8 ' ) ;   
     t r y   {   
         m o d u l e . e x p o r t s   =   J S O N . p a r s e ( i n t e r n a l M o d u l e . s t r i p B O M ( c o n t e n t ) ) ;   
     }   c a t c h   ( e r r )   {   
         e r r . m e s s a g e   =   f i l e n a m e   +   ' :   '   +   e r r . m e s s a g e ;   
         t h r o w   e r r ;   
     }   
 } ;   
   
   
 / / N a t i v e   e x t e n s i o n   f o r   . n o d e   
 M o d u l e . _ e x t e n s i o n s [ ' . n o d e ' ]   =   f u n c t i o n ( m o d u l e ,   f i l e n a m e )   {   
     r e t u r n   p r o c e s s . d l o p e n ( m o d u l e ,   p a t h . _ m a k e L o n g ( f i l e n a m e ) ) ;   
 } ;   
   
 / / S y N o d e   
 M o d u l e . _ e x t e n s i o n s [ p r o c e s s . p l a t f o r m   = = =   ' w i n 3 2 '   ?   ' . d l l '   :   ' . s o ' ]   =   p r o c e s s . b i n d i n g ( ' m o d u l e s ' ) . l o a d D l l ;   
   
 i f   ( e x p e r i m e n t a l M o d u l e s )   {   
     M o d u l e . _ e x t e n s i o n s [ ' . m j s ' ]   =   f u n c t i o n ( m o d u l e ,   f i l e n a m e )   {   
         t h r o w   n e w   e r r o r s . E r r o r ( ' E R R _ R E Q U I R E _ E S M ' ,   f i l e n a m e ) ;   
     } ;   
 }   
   
 / /   b o o t s t r a p   m a i n   m o d u l e .   
 M o d u l e . r u n M a i n   =   f u n c t i o n ( )   {   
     / /   L o a d   t h e   m a i n   m o d u l e - - t h e   c o m m a n d   l i n e   a r g u m e n t .   
     M o d u l e . _ l o a d ( p r o c e s s . a r g v [ 1 ] ,   n u l l ,   t r u e ) ;   
     / /   H a n d l e   a n y   n e x t T i c k s   a d d e d   i n   t h e   f i r s t   t i c k   o f   t h e   p r o g r a m   
     p r o c e s s . _ t i c k C a l l b a c k ( ) ;   
 } ;   
   
 M o d u l e . _ i n i t P a t h s   =   f u n c t i o n ( )   {   
     c o n s t   i s W i n d o w s   =   p r o c e s s . p l a t f o r m   = = =   ' w i n 3 2 ' ;   
   
     v a r   h o m e D i r ;   
     i f   ( i s W i n d o w s )   {   
         h o m e D i r   =   p r o c e s s . e n v . U S E R P R O F I L E ;   
     }   e l s e   {   
         h o m e D i r   =   p r o c e s s . e n v . H O M E ;   
     }   
   
     / /   $ P R E F I X / l i b / n o d e ,   w h e r e   $ P R E F I X   i s   t h e   r o o t   o f   t h e   N o d e . j s   i n s t a l l a t i o n .   
     v a r   p r e f i x D i r ;   
     / /   p r o c e s s . e x e c P a t h   i s   $ P R E F I X / b i n / n o d e   e x c e p t   o n   W i n d o w s   w h e r e   i t   i s   
     / /   $ P R E F I X \ n o d e . e x e .   
     i f   ( i s W i n d o w s )   {   
         p r e f i x D i r   =   p a t h . r e s o l v e ( p r o c e s s . e x e c P a t h ,   ' . . ' ) ;   
     }   e l s e   {   
         p r e f i x D i r   =   p a t h . r e s o l v e ( p r o c e s s . e x e c P a t h ,   ' . . ' ,   ' . . ' ) ;   
     }   
     v a r   p a t h s   =   [ p a t h . r e s o l v e ( p r e f i x D i r ,   ' l i b ' ,   ' n o d e ' ) ] ;   
   
     i f   ( h o m e D i r )   {   
         p a t h s . u n s h i f t ( p a t h . r e s o l v e ( h o m e D i r ,   ' . n o d e _ l i b r a r i e s ' ) ) ;   
         p a t h s . u n s h i f t ( p a t h . r e s o l v e ( h o m e D i r ,   ' . n o d e _ m o d u l e s ' ) ) ;   
     }   
   
     v a r   n o d e P a t h   =   p r o c e s s . e n v [ ' N O D E _ P A T H ' ] ;   
     i f   ( n o d e P a t h )   {   
         p a t h s   =   n o d e P a t h . s p l i t ( p a t h . d e l i m i t e r ) . f i l t e r ( f u n c t i o n ( p a t h )   {   
             r e t u r n   ! ! p a t h ;   
         } ) . c o n c a t ( p a t h s ) ;   
     }   
   
     m o d u l e P a t h s   =   p a t h s ;   
   
     / /   c l o n e   a s   a   s h a l l o w   c o p y ,   f o r   i n t r o s p e c t i o n .   
     M o d u l e . g l o b a l P a t h s   =   m o d u l e P a t h s . s l i c e ( 0 ) ;   
 } ;   
   
 M o d u l e . _ p r e l o a d M o d u l e s   =   f u n c t i o n ( r e q u e s t s )   {   
     i f   ( ! A r r a y . i s A r r a y ( r e q u e s t s ) )   
         r e t u r n ;   
   
     / /   P r e l o a d e d   m o d u l e s   h a v e   a   d u m m y   p a r e n t   m o d u l e   w h i c h   i s   d e e m e d   t o   e x i s t   
     / /   i n   t h e   c u r r e n t   w o r k i n g   d i r e c t o r y .   T h i s   s e e d s   t h e   s e a r c h   p a t h   f o r   
     / /   p r e l o a d e d   m o d u l e s .   
     v a r   p a r e n t   =   n e w   M o d u l e ( ' i n t e r n a l / p r e l o a d ' ,   n u l l ) ;   
     t r y   {   
         p a r e n t . p a t h s   =   M o d u l e . _ n o d e M o d u l e P a t h s ( p r o c e s s . c w d ( ) ) ;   
     }   c a t c h   ( e )   {   
         i f   ( e . c o d e   ! = =   ' E N O E N T ' )   {   
             t h r o w   e ;   
         }   
     }   
     f o r   ( v a r   n   =   0 ;   n   <   r e q u e s t s . l e n g t h ;   n + + )   
         p a r e n t . r e q u i r e ( r e q u e s t s [ n ] ) ;   
 } ;   
   
 M o d u l e . _ i n i t P a t h s ( ) ;   
   
 / /   b a c k w a r d s   c o m p a t i b i l i t y   
 M o d u l e . M o d u l e   =   M o d u l e ;   
 
 } ) ;   �   D   ��
 N O D E _ M O D U L E S / N E T . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ��/ * *   
   *   M P V   -   p u r e   f a k e ! ! ! ! ! !   
   * /   
   
 m o d u l e . e x p o r t s   =   { } 
 } ) ; L  D   ��
 N O D E _ M O D U L E S / O S . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / /   C o p y r i g h t   J o y e n t ,   I n c .   a n d   o t h e r   N o d e   c o n t r i b u t o r s .   
 / /   M o d i f i e d   b y   U n i t y B a s e   c o r e   t e a m   t o   b e   c o m p a t i b l e   w i t h   S y N o d e   
   
 / * *   
   *   @ m o d u l e   o s   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 v a r   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
 c o n s t   { g e t H o s t n a m e }   =   p r o c e s s . b i n d i n g ( ' o s ' )   
   
 / / M P V   T O D O   i m p l e m e n t   
 / / v a r   b i n d i n g   =   p r o c e s s . b i n d i n g ( ' o s ' ) ;   
 / / e x p o r t s . e n d i a n n e s s   =   b i n d i n g . g e t E n d i a n n e s s ;   
 / / e x p o r t s . l o a d a v g   =   b i n d i n g . g e t L o a d A v g ;   
 / / e x p o r t s . u p t i m e   =   b i n d i n g . g e t U p t i m e ;   
 / / e x p o r t s . f r e e m e m   =   b i n d i n g . g e t F r e e M e m ;   
 / / e x p o r t s . t o t a l m e m   =   b i n d i n g . g e t T o t a l M e m ;   
 / / e x p o r t s . c p u s   =   b i n d i n g . g e t C P U s ;   
 / / e x p o r t s . t y p e   =   b i n d i n g . g e t O S T y p e ;   
 / / e x p o r t s . r e l e a s e   =   b i n d i n g . g e t O S R e l e a s e ;   
 / / e x p o r t s . n e t w o r k I n t e r f a c e s   =   b i n d i n g . g e t I n t e r f a c e A d d r e s s e s ;   
   
 e x p o r t s . e n d i a n n e s s   =   f u n c t i o n ( )   {   r e t u r n   ' L E ' ;   } ;   
   
 e x p o r t s . a r c h   =   f u n c t i o n ( )   {   
     r e t u r n   p r o c e s s . a r c h ;   
 } ;   
   
 e x p o r t s . p l a t f o r m   =   f u n c t i o n ( )   {   
     r e t u r n   p r o c e s s . p l a t f o r m ;   
 } ;   
   
 e x p o r t s . t m p d i r   =   f u n c t i o n ( )   {   
     r e t u r n   p r o c e s s . e n v . T M P D I R   | |   
                   p r o c e s s . e n v . T M P   | |   
                   p r o c e s s . e n v . T E M P   | |   
                   ( p r o c e s s . p l a t f o r m   = = =   ' w i n 3 2 '   ?   ' c : \ \ w i n d o w s \ \ t e m p '   :   ' / t m p ' ) ;   
 } ;   
   
 e x p o r t s . t m p D i r   =   e x p o r t s . t m p d i r ;   
   
 e x p o r t s . g e t N e t w o r k I n t e r f a c e s   =   u t i l . d e p r e c a t e ( f u n c t i o n ( )   {   
     r e t u r n   e x p o r t s . n e t w o r k I n t e r f a c e s ( ) ;   
 } ,   ' g e t N e t w o r k I n t e r f a c e s   i s   n o w   c a l l e d   ` o s . n e t w o r k I n t e r f a c e s ` . ' ) ;   
   
 e x p o r t s . E O L   =   p r o c e s s . p l a t f o r m   = = =   ' w i n 3 2 '   ?   ' \ r \ n '   :   ' \ n ' ;   
   
 e x p o r t s . h o s t n a m e   =   f u n c t i o n ( )   {   
     l e t   h n   =   g e t H o s t n a m e ( ) ;   
     r e t u r n   h n . t o L o w e r C a s e ( )   
 }   
 e x p o r t s . h o s t n a m e [ S y m b o l . t o P r i m i t i v e ]   =   ( )   = >   e x p o r t s . h o s t n a m e ( ) ; 
 } ) ; �y H   ��
 N O D E _ M O D U L E S / P A T H . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / * *   
   *   S e e   < a   h r e f = " h t t p s : / / n o d e j s . o r g / a p i / p a t h . h t m l " > N o d e   < s t r o n g > p a t h < / s t r o n g >   m o d u l e   d o c u m e n t a t i o n < / a >   
   *   @ m o d u l e   p a t h   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 ' u s e   s t r i c t ' ;   
   
 c o n s t   i n s p e c t   =   r e q u i r e ( ' u t i l ' ) . i n s p e c t ;   
   
 f u n c t i o n   a s s e r t P a t h ( p a t h )   {   
     i f   ( t y p e o f   p a t h   ! = =   ' s t r i n g ' )   {   
         t h r o w   n e w   T y p e E r r o r ( ' P a t h   m u s t   b e   a   s t r i n g .   R e c e i v e d   '   +   i n s p e c t ( p a t h ) ) ;   
     }   
 }   
   
 / /   R e s o l v e s   .   a n d   . .   e l e m e n t s   i n   a   p a t h   w i t h   d i r e c t o r y   n a m e s   
 f u n c t i o n   n o r m a l i z e S t r i n g W i n 3 2 ( p a t h ,   a l l o w A b o v e R o o t )   {   
     v a r   r e s   =   ' ' ;   
     v a r   l a s t S l a s h   =   - 1 ;   
     v a r   d o t s   =   0 ;   
     v a r   c o d e ;   
     f o r   ( v a r   i   =   0 ;   i   < =   p a t h . l e n g t h ;   + + i )   {   
         i f   ( i   <   p a t h . l e n g t h )   
             c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
         e l s e   i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
             b r e a k ;   
         e l s e   
             c o d e   =   4 7 / * / * / ;   
         i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
             i f   ( l a s t S l a s h   = = =   i   -   1   | |   d o t s   = = =   1 )   {   
                 / /   N O O P   
             }   e l s e   i f   ( l a s t S l a s h   ! = =   i   -   1   & &   d o t s   = = =   2 )   {   
                 i f   ( r e s . l e n g t h   <   2   | |   
                         r e s . c h a r C o d e A t ( r e s . l e n g t h   -   1 )   ! = =   4 6 / * . * /   | |   
                         r e s . c h a r C o d e A t ( r e s . l e n g t h   -   2 )   ! = =   4 6 / * . * / )   {   
                     i f   ( r e s . l e n g t h   >   2 )   {   
                         c o n s t   s t a r t   =   r e s . l e n g t h   -   1 ;   
                         v a r   j   =   s t a r t ;   
                         f o r   ( ;   j   > =   0 ;   - - j )   {   
                             i f   ( r e s . c h a r C o d e A t ( j )   = = =   9 2 / * \ * / )   
                                 b r e a k ;   
                         }   
                         i f   ( j   ! = =   s t a r t )   {   
                             i f   ( j   = = =   - 1 )   
                                 r e s   =   ' ' ;   
                             e l s e   
                                 r e s   =   r e s . s l i c e ( 0 ,   j ) ;   
                             l a s t S l a s h   =   i ;   
                             d o t s   =   0 ;   
                             c o n t i n u e ;   
                         }   
                     }   e l s e   i f   ( r e s . l e n g t h   = = =   2   | |   r e s . l e n g t h   = = =   1 )   {   
                         r e s   =   ' ' ;   
                         l a s t S l a s h   =   i ;   
                         d o t s   =   0 ;   
                         c o n t i n u e ;   
                     }   
                 }   
                 i f   ( a l l o w A b o v e R o o t )   {   
                     i f   ( r e s . l e n g t h   >   0 )   
                         r e s   + =   ' \ \ . . ' ;   
                     e l s e   
                         r e s   =   ' . . ' ;   
                 }   
             }   e l s e   {   
                 i f   ( r e s . l e n g t h   >   0 )   
                     r e s   + =   ' \ \ '   +   p a t h . s l i c e ( l a s t S l a s h   +   1 ,   i ) ;   
                 e l s e   
                     r e s   =   p a t h . s l i c e ( l a s t S l a s h   +   1 ,   i ) ;   
             }   
             l a s t S l a s h   =   i ;   
             d o t s   =   0 ;   
         }   e l s e   i f   ( c o d e   = = =   4 6 / * . * /   & &   d o t s   ! = =   - 1 )   {   
             + + d o t s ;   
         }   e l s e   {   
             d o t s   =   - 1 ;   
         }   
     }   
     r e t u r n   r e s ;   
 }   
   
 / /   R e s o l v e s   .   a n d   . .   e l e m e n t s   i n   a   p a t h   w i t h   d i r e c t o r y   n a m e s   
 f u n c t i o n   n o r m a l i z e S t r i n g P o s i x ( p a t h ,   a l l o w A b o v e R o o t )   {   
     v a r   r e s   =   ' ' ;   
     v a r   l a s t S l a s h   =   - 1 ;   
     v a r   d o t s   =   0 ;   
     v a r   c o d e ;   
     f o r   ( v a r   i   =   0 ;   i   < =   p a t h . l e n g t h ;   + + i )   {   
         i f   ( i   <   p a t h . l e n g t h )   
             c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
         e l s e   i f   ( c o d e   = = =   4 7 / * / * / )   
             b r e a k ;   
         e l s e   
             c o d e   =   4 7 / * / * / ;   
         i f   ( c o d e   = = =   4 7 / * / * / )   {   
             i f   ( l a s t S l a s h   = = =   i   -   1   | |   d o t s   = = =   1 )   {   
                 / /   N O O P   
             }   e l s e   i f   ( l a s t S l a s h   ! = =   i   -   1   & &   d o t s   = = =   2 )   {   
                 i f   ( r e s . l e n g t h   <   2   | |   
                         r e s . c h a r C o d e A t ( r e s . l e n g t h   -   1 )   ! = =   4 6 / * . * /   | |   
                         r e s . c h a r C o d e A t ( r e s . l e n g t h   -   2 )   ! = =   4 6 / * . * / )   {   
                     i f   ( r e s . l e n g t h   >   2 )   {   
                         c o n s t   s t a r t   =   r e s . l e n g t h   -   1 ;   
                         v a r   j   =   s t a r t ;   
                         f o r   ( ;   j   > =   0 ;   - - j )   {   
                             i f   ( r e s . c h a r C o d e A t ( j )   = = =   4 7 / * / * / )   
                                 b r e a k ;   
                         }   
                         i f   ( j   ! = =   s t a r t )   {   
                             i f   ( j   = = =   - 1 )   
                                 r e s   =   ' ' ;   
                             e l s e   
                                 r e s   =   r e s . s l i c e ( 0 ,   j ) ;   
                             l a s t S l a s h   =   i ;   
                             d o t s   =   0 ;   
                             c o n t i n u e ;   
                         }   
                     }   e l s e   i f   ( r e s . l e n g t h   = = =   2   | |   r e s . l e n g t h   = = =   1 )   {   
                         r e s   =   ' ' ;   
                         l a s t S l a s h   =   i ;   
                         d o t s   =   0 ;   
                         c o n t i n u e ;   
                     }   
                 }   
                 i f   ( a l l o w A b o v e R o o t )   {   
                     i f   ( r e s . l e n g t h   >   0 )   
                         r e s   + =   ' / . . ' ;   
                     e l s e   
                         r e s   =   ' . . ' ;   
                 }   
             }   e l s e   {   
                 i f   ( r e s . l e n g t h   >   0 )   
                     r e s   + =   ' / '   +   p a t h . s l i c e ( l a s t S l a s h   +   1 ,   i ) ;   
                 e l s e   
                     r e s   =   p a t h . s l i c e ( l a s t S l a s h   +   1 ,   i ) ;   
             }   
             l a s t S l a s h   =   i ;   
             d o t s   =   0 ;   
         }   e l s e   i f   ( c o d e   = = =   4 6 / * . * /   & &   d o t s   ! = =   - 1 )   {   
             + + d o t s ;   
         }   e l s e   {   
             d o t s   =   - 1 ;   
         }   
     }   
     r e t u r n   r e s ;   
 }   
   
 f u n c t i o n   _ f o r m a t ( s e p ,   p a t h O b j e c t )   {   
     c o n s t   d i r   =   p a t h O b j e c t . d i r   | |   p a t h O b j e c t . r o o t ;   
     c o n s t   b a s e   =   p a t h O b j e c t . b a s e   | |   
         ( ( p a t h O b j e c t . n a m e   | |   ' ' )   +   ( p a t h O b j e c t . e x t   | |   ' ' ) ) ;   
     i f   ( ! d i r )   {   
         r e t u r n   b a s e ;   
     }   
     i f   ( d i r   = = =   p a t h O b j e c t . r o o t )   {   
         r e t u r n   d i r   +   b a s e ;   
     }   
     r e t u r n   d i r   +   s e p   +   b a s e ;   
 }   
   
 c o n s t   w i n 3 2   =   {   
     / /   p a t h . r e s o l v e ( [ f r o m   . . . ] ,   t o )   
     r e s o l v e :   f u n c t i o n   r e s o l v e ( )   {   
         v a r   r e s o l v e d D e v i c e   =   ' ' ;   
         v a r   r e s o l v e d T a i l   =   ' ' ;   
         v a r   r e s o l v e d A b s o l u t e   =   f a l s e ;   
   
         f o r   ( v a r   i   =   a r g u m e n t s . l e n g t h   -   1 ;   i   > =   - 1 ;   i - - )   {   
             v a r   p a t h ;   
             i f   ( i   > =   0 )   {   
                 p a t h   =   a r g u m e n t s [ i ] ;   
             }   e l s e   i f   ( ! r e s o l v e d D e v i c e )   {   
                 p a t h   =   p r o c e s s . c w d ( ) ;   
             }   e l s e   {   
                 / /   W i n d o w s   h a s   t h e   c o n c e p t   o f   d r i v e - s p e c i f i c   c u r r e n t   w o r k i n g   
                 / /   d i r e c t o r i e s .   I f   w e ' v e   r e s o l v e d   a   d r i v e   l e t t e r   b u t   n o t   y e t   a n   
                 / /   a b s o l u t e   p a t h ,   g e t   c w d   f o r   t h a t   d r i v e ,   o r   t h e   p r o c e s s   c w d   i f   
                 / /   t h e   d r i v e   c w d   i s   n o t   a v a i l a b l e .   W e ' r e   s u r e   t h e   d e v i c e   i s   n o t   
                 / /   a   U N C   p a t h   a t   t h i s   p o i n t s ,   b e c a u s e   U N C   p a t h s   a r e   a l w a y s   a b s o l u t e .   
                 p a t h   =   p r o c e s s . e n v [ ' = '   +   r e s o l v e d D e v i c e ]   | |   p r o c e s s . c w d ( ) ;   
   
                 / /   V e r i f y   t h a t   a   c w d   w a s   f o u n d   a n d   t h a t   i t   a c t u a l l y   p o i n t s   
                 / /   t o   o u r   d r i v e .   I f   n o t ,   d e f a u l t   t o   t h e   d r i v e ' s   r o o t .   
                 i f   ( p a t h   = = =   u n d e f i n e d   | |   
                         p a t h . s l i c e ( 0 ,   3 ) . t o L o w e r C a s e ( )   ! = =   
                             r e s o l v e d D e v i c e . t o L o w e r C a s e ( )   +   ' \ \ ' )   {   
                     p a t h   =   r e s o l v e d D e v i c e   +   ' \ \ ' ;   
                 }   
             }   
   
             a s s e r t P a t h ( p a t h ) ;   
   
             / /   S k i p   e m p t y   e n t r i e s   
             i f   ( p a t h . l e n g t h   = = =   0 )   {   
                 c o n t i n u e ;   
             }   
   
             v a r   l e n   =   p a t h . l e n g t h ;   
             v a r   r o o t E n d   =   0 ;   
             v a r   c o d e   =   p a t h . c h a r C o d e A t ( 0 ) ;   
             v a r   d e v i c e   =   ' ' ;   
             v a r   i s A b s o l u t e   =   f a l s e ;   
   
             / /   T r y   t o   m a t c h   a   r o o t   
             i f   ( l e n   >   1 )   {   
                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                     / /   P o s s i b l e   U N C   r o o t   
   
                     / /   I f   w e   s t a r t e d   w i t h   a   s e p a r a t o r ,   w e   k n o w   w e   a t   l e a s t   h a v e   a n   
                     / /   a b s o l u t e   p a t h   o f   s o m e   k i n d   ( U N C   o r   o t h e r w i s e )   
                     i s A b s o l u t e   =   t r u e ;   
   
                     c o d e   =   p a t h . c h a r C o d e A t ( 1 ) ;   
                     i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                         / /   M a t c h e d   d o u b l e   p a t h   s e p a r a t o r   a t   b e g i n n i n g   
                         v a r   j   =   2 ;   
                         v a r   l a s t   =   j ;   
                         / /   M a t c h   1   o r   m o r e   n o n - p a t h   s e p a r a t o r s   
                         f o r   ( ;   j   <   l e n ;   + + j )   {   
                             c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                             i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                                 b r e a k ;   
                         }   
                         i f   ( j   <   l e n   & &   j   ! = =   l a s t )   {   
                             c o n s t   f i r s t P a r t   =   p a t h . s l i c e ( l a s t ,   j ) ;   
                             / /   M a t c h e d !   
                             l a s t   =   j ;   
                             / /   M a t c h   1   o r   m o r e   p a t h   s e p a r a t o r s   
                             f o r   ( ;   j   <   l e n ;   + + j )   {   
                                 c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                                 i f   ( c o d e   ! = =   4 7 / * / * /   & &   c o d e   ! = =   9 2 / * \ * / )   
                                     b r e a k ;   
                             }   
                             i f   ( j   <   l e n   & &   j   ! = =   l a s t )   {   
                                 / /   M a t c h e d !   
                                 l a s t   =   j ;   
                                 / /   M a t c h   1   o r   m o r e   n o n - p a t h   s e p a r a t o r s   
                                 f o r   ( ;   j   <   l e n ;   + + j )   {   
                                     c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                                     i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                                         b r e a k ;   
                                 }   
                                 i f   ( j   = = =   l e n )   {   
                                     / /   W e   m a t c h e d   a   U N C   r o o t   o n l y   
   
                                     d e v i c e   =   ' \ \ \ \ '   +   f i r s t P a r t   +   ' \ \ '   +   p a t h . s l i c e ( l a s t ) ;   
                                     r o o t E n d   =   j ;   
                                 }   e l s e   i f   ( j   ! = =   l a s t )   {   
                                     / /   W e   m a t c h e d   a   U N C   r o o t   w i t h   l e f t o v e r s   
   
                                     d e v i c e   =   ' \ \ \ \ '   +   f i r s t P a r t   +   ' \ \ '   +   p a t h . s l i c e ( l a s t ,   j ) ;   
                                     r o o t E n d   =   j ;   
                                 }   
                             }   
                         }   
                     }   e l s e   {   
                         r o o t E n d   =   1 ;   
                     }   
                 }   e l s e   i f   ( ( c o d e   > =   6 5 / * A * /   & &   c o d e   < =   9 0 / * Z * / )   | |   
                                       ( c o d e   > =   9 7 / * a * /   & &   c o d e   < =   1 2 2 / * z * / ) )   {   
                     / /   P o s s i b l e   d e v i c e   r o o t   
   
                     c o d e   =   p a t h . c h a r C o d e A t ( 1 ) ;   
                     i f   ( p a t h . c h a r C o d e A t ( 1 )   = = =   5 8 / * : * / )   {   
                         d e v i c e   =   p a t h . s l i c e ( 0 ,   2 ) ;   
                         r o o t E n d   =   2 ;   
                         i f   ( l e n   >   2 )   {   
                             c o d e   =   p a t h . c h a r C o d e A t ( 2 ) ;   
                             i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                                 / /   T r e a t   s e p a r a t o r   f o l l o w i n g   d r i v e   n a m e   a s   a n   a b s o l u t e   p a t h   
                                 / /   i n d i c a t o r   
                                 i s A b s o l u t e   =   t r u e ;   
                                 r o o t E n d   =   3 ;   
                             }   
                         }   
                     }   
                 }   
             }   e l s e   i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                 / /   ` p a t h `   c o n t a i n s   j u s t   a   p a t h   s e p a r a t o r   
                 r o o t E n d   =   1 ;   
                 i s A b s o l u t e   =   t r u e ;   
             }   
   
             i f   ( d e v i c e . l e n g t h   >   0   & &   
                     r e s o l v e d D e v i c e . l e n g t h   >   0   & &   
                     d e v i c e . t o L o w e r C a s e ( )   ! = =   r e s o l v e d D e v i c e . t o L o w e r C a s e ( ) )   {   
                 / /   T h i s   p a t h   p o i n t s   t o   a n o t h e r   d e v i c e   s o   i t   i s   n o t   a p p l i c a b l e   
                 c o n t i n u e ;   
             }   
   
             i f   ( r e s o l v e d D e v i c e . l e n g t h   = = =   0   & &   d e v i c e . l e n g t h   >   0 )   {   
                 r e s o l v e d D e v i c e   =   d e v i c e ;   
             }   
             i f   ( ! r e s o l v e d A b s o l u t e )   {   
                 r e s o l v e d T a i l   =   p a t h . s l i c e ( r o o t E n d )   +   ' \ \ '   +   r e s o l v e d T a i l ;   
                 r e s o l v e d A b s o l u t e   =   i s A b s o l u t e ;   
             }   
   
             i f   ( r e s o l v e d D e v i c e . l e n g t h   >   0   & &   r e s o l v e d A b s o l u t e )   {   
                 b r e a k ;   
             }   
         }   
   
         / /   A t   t h i s   p o i n t   t h e   p a t h   s h o u l d   b e   r e s o l v e d   t o   a   f u l l   a b s o l u t e   p a t h ,   
         / /   b u t   h a n d l e   r e l a t i v e   p a t h s   t o   b e   s a f e   ( m i g h t   h a p p e n   w h e n   p r o c e s s . c w d ( )   
         / /   f a i l s )   
   
         / /   N o r m a l i z e   t h e   t a i l   p a t h   
         r e s o l v e d T a i l   =   n o r m a l i z e S t r i n g W i n 3 2 ( r e s o l v e d T a i l ,   ! r e s o l v e d A b s o l u t e ) ;   
   
         r e t u r n   ( r e s o l v e d D e v i c e   +   ( r e s o l v e d A b s o l u t e   ?   ' \ \ '   :   ' ' )   +   r e s o l v e d T a i l )   | |   
                       ' . ' ;   
     } ,   
   
     n o r m a l i z e :   f u n c t i o n   n o r m a l i z e ( p a t h )   {   
         a s s e r t P a t h ( p a t h ) ;   
         c o n s t   l e n   =   p a t h . l e n g t h ;   
         i f   ( l e n   = = =   0 )   
             r e t u r n   ' . ' ;   
         v a r   r o o t E n d   =   0 ;   
         v a r   c o d e   =   p a t h . c h a r C o d e A t ( 0 ) ;   
         v a r   d e v i c e ;   
         v a r   i s A b s o l u t e   =   f a l s e ;   
   
         / /   T r y   t o   m a t c h   a   r o o t   
         i f   ( l e n   >   1 )   {   
             i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                 / /   P o s s i b l e   U N C   r o o t   
   
                 / /   I f   w e   s t a r t e d   w i t h   a   s e p a r a t o r ,   w e   k n o w   w e   a t   l e a s t   h a v e   a n   a b s o l u t e   
                 / /   p a t h   o f   s o m e   k i n d   ( U N C   o r   o t h e r w i s e )   
                 i s A b s o l u t e   =   t r u e ;   
   
                 c o d e   =   p a t h . c h a r C o d e A t ( 1 ) ;   
                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                     / /   M a t c h e d   d o u b l e   p a t h   s e p a r a t o r   a t   b e g i n n i n g   
                     v a r   j   =   2 ;   
                     v a r   l a s t   =   j ;   
                     / /   M a t c h   1   o r   m o r e   n o n - p a t h   s e p a r a t o r s   
                     f o r   ( ;   j   <   l e n ;   + + j )   {   
                         c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                         i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                             b r e a k ;   
                     }   
                     i f   ( j   <   l e n   & &   j   ! = =   l a s t )   {   
                         c o n s t   f i r s t P a r t   =   p a t h . s l i c e ( l a s t ,   j ) ;   
                         / /   M a t c h e d !   
                         l a s t   =   j ;   
                         / /   M a t c h   1   o r   m o r e   p a t h   s e p a r a t o r s   
                         f o r   ( ;   j   <   l e n ;   + + j )   {   
                             c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                             i f   ( c o d e   ! = =   4 7 / * / * /   & &   c o d e   ! = =   9 2 / * \ * / )   
                                 b r e a k ;   
                         }   
                         i f   ( j   <   l e n   & &   j   ! = =   l a s t )   {   
                             / /   M a t c h e d !   
                             l a s t   =   j ;   
                             / /   M a t c h   1   o r   m o r e   n o n - p a t h   s e p a r a t o r s   
                             f o r   ( ;   j   <   l e n ;   + + j )   {   
                                 c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                                     b r e a k ;   
                             }   
                             i f   ( j   = = =   l e n )   {   
                                 / /   W e   m a t c h e d   a   U N C   r o o t   o n l y   
                                 / /   R e t u r n   t h e   n o r m a l i z e d   v e r s i o n   o f   t h e   U N C   r o o t   s i n c e   t h e r e   
                                 / /   i s   n o t h i n g   l e f t   t o   p r o c e s s   
   
                                 r e t u r n   ' \ \ \ \ '   +   f i r s t P a r t   +   ' \ \ '   +   p a t h . s l i c e ( l a s t )   +   ' \ \ ' ;   
                             }   e l s e   i f   ( j   ! = =   l a s t )   {   
                                 / /   W e   m a t c h e d   a   U N C   r o o t   w i t h   l e f t o v e r s   
   
                                 d e v i c e   =   ' \ \ \ \ '   +   f i r s t P a r t   +   ' \ \ '   +   p a t h . s l i c e ( l a s t ,   j ) ;   
                                 r o o t E n d   =   j ;   
                             }   
                         }   
                     }   
                 }   e l s e   {   
                     r o o t E n d   =   1 ;   
                 }   
             }   e l s e   i f   ( ( c o d e   > =   6 5 / * A * /   & &   c o d e   < =   9 0 / * Z * / )   | |   
                                   ( c o d e   > =   9 7 / * a * /   & &   c o d e   < =   1 2 2 / * z * / ) )   {   
                 / /   P o s s i b l e   d e v i c e   r o o t   
   
                 c o d e   =   p a t h . c h a r C o d e A t ( 1 ) ;   
                 i f   ( p a t h . c h a r C o d e A t ( 1 )   = = =   5 8 / * : * / )   {   
                     d e v i c e   =   p a t h . s l i c e ( 0 ,   2 ) ;   
                     r o o t E n d   =   2 ;   
                     i f   ( l e n   >   2 )   {   
                         c o d e   =   p a t h . c h a r C o d e A t ( 2 ) ;   
                         i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                             / /   T r e a t   s e p a r a t o r   f o l l o w i n g   d r i v e   n a m e   a s   a n   a b s o l u t e   p a t h   
                             / /   i n d i c a t o r   
                             i s A b s o l u t e   =   t r u e ;   
                             r o o t E n d   =   3 ;   
                         }   
                     }   
                 }   
             }   
         }   e l s e   i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
             / /   ` p a t h `   c o n t a i n s   j u s t   a   p a t h   s e p a r a t o r ,   e x i t   e a r l y   t o   a v o i d   u n n e c e s s a r y   
             / /   w o r k   
             r e t u r n   ' \ \ ' ;   
         }   
   
         c o d e   =   p a t h . c h a r C o d e A t ( l e n   -   1 ) ;   
         v a r   t r a i l i n g S e p a r a t o r   =   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / ) ;   
         v a r   t a i l ;   
         i f   ( r o o t E n d   <   l e n )   
             t a i l   =   n o r m a l i z e S t r i n g W i n 3 2 ( p a t h . s l i c e ( r o o t E n d ) ,   ! i s A b s o l u t e ) ;   
         e l s e   
             t a i l   =   ' ' ;   
         i f   ( t a i l . l e n g t h   = = =   0   & &   ! i s A b s o l u t e )   
             t a i l   =   ' . ' ;   
         i f   ( t a i l . l e n g t h   >   0   & &   t r a i l i n g S e p a r a t o r )   
             t a i l   + =   ' \ \ ' ;   
         i f   ( d e v i c e   = = =   u n d e f i n e d )   {   
             i f   ( i s A b s o l u t e )   {   
                 i f   ( t a i l . l e n g t h   >   0 )   
                     r e t u r n   ' \ \ '   +   t a i l ;   
                 e l s e   
                     r e t u r n   ' \ \ ' ;   
             }   e l s e   i f   ( t a i l . l e n g t h   >   0 )   {   
                 r e t u r n   t a i l ;   
             }   e l s e   {   
                 r e t u r n   ' ' ;   
             }   
         }   e l s e   {   
             i f   ( i s A b s o l u t e )   {   
                 i f   ( t a i l . l e n g t h   >   0 )   
                     r e t u r n   d e v i c e   +   ' \ \ '   +   t a i l ;   
                 e l s e   
                     r e t u r n   d e v i c e   +   ' \ \ ' ;   
             }   e l s e   i f   ( t a i l . l e n g t h   >   0 )   {   
                 r e t u r n   d e v i c e   +   t a i l ;   
             }   e l s e   {   
                 r e t u r n   d e v i c e ;   
             }   
         }   
     } ,   
   
   
     i s A b s o l u t e :   f u n c t i o n   i s A b s o l u t e ( p a t h )   {   
         a s s e r t P a t h ( p a t h ) ;   
         c o n s t   l e n   =   p a t h . l e n g t h ;   
         i f   ( l e n   = = =   0 )   
             r e t u r n   f a l s e ;   
         v a r   c o d e   =   p a t h . c h a r C o d e A t ( 0 ) ;   
         i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
             r e t u r n   t r u e ;   
         }   e l s e   i f   ( ( c o d e   > =   6 5 / * A * /   & &   c o d e   < =   9 0 / * Z * / )   | |   
                               ( c o d e   > =   9 7 / * a * /   & &   c o d e   < =   1 2 2 / * z * / ) )   {   
             / /   P o s s i b l e   d e v i c e   r o o t   
   
             i f   ( l e n   >   2   & &   p a t h . c h a r C o d e A t ( 1 )   = = =   5 8 / * : * / )   {   
                 c o d e   =   p a t h . c h a r C o d e A t ( 2 ) ;   
                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                     r e t u r n   t r u e ;   
             }   
         }   
         r e t u r n   f a l s e ;   
     } ,   
   
   
     j o i n :   f u n c t i o n   j o i n ( )   {   
         i f   ( a r g u m e n t s . l e n g t h   = = =   0 )   
             r e t u r n   ' . ' ;   
   
         v a r   j o i n e d ;   
         v a r   f i r s t P a r t ;   
         f o r   ( v a r   i   =   0 ;   i   <   a r g u m e n t s . l e n g t h ;   + + i )   {   
             v a r   a r g   =   a r g u m e n t s [ i ] ;   
             a s s e r t P a t h ( a r g ) ;   
             i f   ( a r g . l e n g t h   >   0 )   {   
                 i f   ( j o i n e d   = = =   u n d e f i n e d )   
                     j o i n e d   =   f i r s t P a r t   =   a r g ;   
                 e l s e   
                     j o i n e d   + =   ' \ \ '   +   a r g ;   
             }   
         }   
   
         i f   ( j o i n e d   = = =   u n d e f i n e d )   
             r e t u r n   ' . ' ;   
   
         / /   M a k e   s u r e   t h a t   t h e   j o i n e d   p a t h   d o e s n ' t   s t a r t   w i t h   t w o   s l a s h e s ,   b e c a u s e   
         / /   n o r m a l i z e ( )   w i l l   m i s t a k e   i t   f o r   a n   U N C   p a t h   t h e n .   
         / /   
         / /   T h i s   s t e p   i s   s k i p p e d   w h e n   i t   i s   v e r y   c l e a r   t h a t   t h e   u s e r   a c t u a l l y   
         / /   i n t e n d e d   t o   p o i n t   a t   a n   U N C   p a t h .   T h i s   i s   a s s u m e d   w h e n   t h e   f i r s t   
         / /   n o n - e m p t y   s t r i n g   a r g u m e n t s   s t a r t s   w i t h   e x a c t l y   t w o   s l a s h e s   f o l l o w e d   b y   
         / /   a t   l e a s t   o n e   m o r e   n o n - s l a s h   c h a r a c t e r .   
         / /   
         / /   N o t e   t h a t   f o r   n o r m a l i z e ( )   t o   t r e a t   a   p a t h   a s   a n   U N C   p a t h   i t   n e e d s   t o   
         / /   h a v e   a t   l e a s t   2   c o m p o n e n t s ,   s o   w e   d o n ' t   f i l t e r   f o r   t h a t   h e r e .   
         / /   T h i s   m e a n s   t h a t   t h e   u s e r   c a n   u s e   j o i n   t o   c o n s t r u c t   U N C   p a t h s   f r o m   
         / /   a   s e r v e r   n a m e   a n d   a   s h a r e   n a m e ;   f o r   e x a m p l e :   
         / /       p a t h . j o i n ( ' / / s e r v e r ' ,   ' s h a r e ' )   - >   ' \ \ \ \ s e r v e r \ \ s h a r e \ \ ' )   
         / / v a r   f i r s t P a r t   =   p a t h s [ 0 ] ;   
         v a r   n e e d s R e p l a c e   =   t r u e ;   
         v a r   s l a s h C o u n t   =   0 ;   
         v a r   c o d e   =   f i r s t P a r t . c h a r C o d e A t ( 0 ) ;   
         i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
             + + s l a s h C o u n t ;   
             c o n s t   f i r s t L e n   =   f i r s t P a r t . l e n g t h ;   
             i f   ( f i r s t L e n   >   1 )   {   
                 c o d e   =   f i r s t P a r t . c h a r C o d e A t ( 1 ) ;   
                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                     + + s l a s h C o u n t ;   
                     i f   ( f i r s t L e n   >   2 )   {   
                         c o d e   =   f i r s t P a r t . c h a r C o d e A t ( 2 ) ;   
                         i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                             + + s l a s h C o u n t ;   
                         e l s e   {   
                             / /   W e   m a t c h e d   a   U N C   p a t h   i n   t h e   f i r s t   p a r t   
                             n e e d s R e p l a c e   =   f a l s e ;   
                         }   
                     }   
                 }   
             }   
         }   
         i f   ( n e e d s R e p l a c e )   {   
             / /   F i n d   a n y   m o r e   c o n s e c u t i v e   s l a s h e s   w e   n e e d   t o   r e p l a c e   
             f o r   ( ;   s l a s h C o u n t   <   j o i n e d . l e n g t h ;   + + s l a s h C o u n t )   {   
                 c o d e   =   j o i n e d . c h a r C o d e A t ( s l a s h C o u n t ) ;   
                 i f   ( c o d e   ! = =   4 7 / * / * /   & &   c o d e   ! = =   9 2 / * \ * / )   
                     b r e a k ;   
             }   
   
             / /   R e p l a c e   t h e   s l a s h e s   i f   n e e d e d   
             i f   ( s l a s h C o u n t   > =   2 )   
                 j o i n e d   =   ' \ \ '   +   j o i n e d . s l i c e ( s l a s h C o u n t ) ;   
         }   
   
         r e t u r n   w i n 3 2 . n o r m a l i z e ( j o i n e d ) ;   
     } ,   
   
   
     / /   I t   w i l l   s o l v e   t h e   r e l a t i v e   p a t h   f r o m   ` f r o m `   t o   ` t o ` ,   f o r   i n s t a n c e :   
     / /     f r o m   =   ' C : \ \ o r a n d e a \ \ t e s t \ \ a a a '   
     / /     t o   =   ' C : \ \ o r a n d e a \ \ i m p l \ \ b b b '   
     / /   T h e   o u t p u t   o f   t h e   f u n c t i o n   s h o u l d   b e :   ' . . \ \ . . \ \ i m p l \ \ b b b '   
     r e l a t i v e :   f u n c t i o n   r e l a t i v e ( f r o m ,   t o )   {   
         a s s e r t P a t h ( f r o m ) ;   
         a s s e r t P a t h ( t o ) ;   
   
         i f   ( f r o m   = = =   t o )   
             r e t u r n   ' ' ;   
   
         v a r   f r o m O r i g   =   w i n 3 2 . r e s o l v e ( f r o m ) ;   
         v a r   t o O r i g   =   w i n 3 2 . r e s o l v e ( t o ) ;   
   
         i f   ( f r o m O r i g   = = =   t o O r i g )   
             r e t u r n   ' ' ;   
   
         f r o m   =   f r o m O r i g . t o L o w e r C a s e ( ) ;   
         t o   =   t o O r i g . t o L o w e r C a s e ( ) ;   
   
         i f   ( f r o m   = = =   t o )   
             r e t u r n   ' ' ;   
   
         / /   T r i m   a n y   l e a d i n g   b a c k s l a s h e s   
         v a r   f r o m S t a r t   =   0 ;   
         f o r   ( ;   f r o m S t a r t   <   f r o m . l e n g t h ;   + + f r o m S t a r t )   {   
             i f   ( f r o m . c h a r C o d e A t ( f r o m S t a r t )   ! = =   9 2 / * \ * / )   
                 b r e a k ;   
         }   
         / /   T r i m   t r a i l i n g   b a c k s l a s h e s   ( a p p l i c a b l e   t o   U N C   p a t h s   o n l y )   
         v a r   f r o m E n d   =   f r o m . l e n g t h ;   
         f o r   ( ;   f r o m E n d   -   1   >   f r o m S t a r t ;   - - f r o m E n d )   {   
             i f   ( f r o m . c h a r C o d e A t ( f r o m E n d   -   1 )   ! = =   9 2 / * \ * / )   
                 b r e a k ;   
         }   
         v a r   f r o m L e n   =   ( f r o m E n d   -   f r o m S t a r t ) ;   
   
         / /   T r i m   a n y   l e a d i n g   b a c k s l a s h e s   
         v a r   t o S t a r t   =   0 ;   
         f o r   ( ;   t o S t a r t   <   t o . l e n g t h ;   + + t o S t a r t )   {   
             i f   ( t o . c h a r C o d e A t ( t o S t a r t )   ! = =   9 2 / * \ * / )   
                 b r e a k ;   
         }   
         / /   T r i m   t r a i l i n g   b a c k s l a s h e s   ( a p p l i c a b l e   t o   U N C   p a t h s   o n l y )   
         v a r   t o E n d   =   t o . l e n g t h ;   
         f o r   ( ;   t o E n d   -   1   >   t o S t a r t ;   - - t o E n d )   {   
             i f   ( t o . c h a r C o d e A t ( t o E n d   -   1 )   ! = =   9 2 / * \ * / )   
                 b r e a k ;   
         }   
         v a r   t o L e n   =   ( t o E n d   -   t o S t a r t ) ;   
   
         / /   C o m p a r e   p a t h s   t o   f i n d   t h e   l o n g e s t   c o m m o n   p a t h   f r o m   r o o t   
         v a r   l e n g t h   =   ( f r o m L e n   <   t o L e n   ?   f r o m L e n   :   t o L e n ) ;   
         v a r   l a s t C o m m o n S e p   =   - 1 ;   
         v a r   i   =   0 ;   
         f o r   ( ;   i   < =   l e n g t h ;   + + i )   {   
             i f   ( i   = = =   l e n g t h )   {   
                 i f   ( t o L e n   >   l e n g t h )   {   
                     i f   ( t o . c h a r C o d e A t ( t o S t a r t   +   i )   = = =   9 2 / * \ * / )   {   
                         / /   W e   g e t   h e r e   i f   ` f r o m `   i s   t h e   e x a c t   b a s e   p a t h   f o r   ` t o ` .   
                         / /   F o r   e x a m p l e :   f r o m = ' C : \ \ f o o \ \ b a r ' ;   t o = ' C : \ \ f o o \ \ b a r \ \ b a z '   
                         r e t u r n   t o O r i g . s l i c e ( t o S t a r t   +   i   +   1 ) ;   
                     }   e l s e   i f   ( i   = = =   2 )   {   
                         / /   W e   g e t   h e r e   i f   ` f r o m `   i s   t h e   d e v i c e   r o o t .   
                         / /   F o r   e x a m p l e :   f r o m = ' C : \ \ ' ;   t o = ' C : \ \ f o o '   
                         r e t u r n   t o O r i g . s l i c e ( t o S t a r t   +   i ) ;   
                     }   
                 }   
                 i f   ( f r o m L e n   >   l e n g t h )   {   
                     i f   ( f r o m . c h a r C o d e A t ( f r o m S t a r t   +   i )   = = =   9 2 / * \ * / )   {   
                         / /   W e   g e t   h e r e   i f   ` t o `   i s   t h e   e x a c t   b a s e   p a t h   f o r   ` f r o m ` .   
                         / /   F o r   e x a m p l e :   f r o m = ' C : \ \ f o o \ \ b a r ' ;   t o = ' C : \ \ f o o '   
                         l a s t C o m m o n S e p   =   i ;   
                     }   e l s e   i f   ( i   = = =   2 )   {   
                         / /   W e   g e t   h e r e   i f   ` t o `   i s   t h e   d e v i c e   r o o t .   
                         / /   F o r   e x a m p l e :   f r o m = ' C : \ \ f o o \ \ b a r ' ;   t o = ' C : \ \ '   
                         l a s t C o m m o n S e p   =   3 ;   
                     }   
                 }   
                 b r e a k ;   
             }   
             v a r   f r o m C o d e   =   f r o m . c h a r C o d e A t ( f r o m S t a r t   +   i ) ;   
             v a r   t o C o d e   =   t o . c h a r C o d e A t ( t o S t a r t   +   i ) ;   
             i f   ( f r o m C o d e   ! = =   t o C o d e )   
                 b r e a k ;   
             e l s e   i f   ( f r o m C o d e   = = =   9 2 / * \ * / )   
                 l a s t C o m m o n S e p   =   i ;   
         }   
   
         / /   W e   f o u n d   a   m i s m a t c h   b e f o r e   t h e   f i r s t   c o m m o n   p a t h   s e p a r a t o r   w a s   s e e n ,   s o   
         / /   r e t u r n   t h e   o r i g i n a l   ` t o ` .   
         i f   ( i   ! = =   l e n g t h   & &   l a s t C o m m o n S e p   = = =   - 1 )   {   
             r e t u r n   t o O r i g ;   
         }   
   
         v a r   o u t   =   ' ' ;   
         i f   ( l a s t C o m m o n S e p   = = =   - 1 )   
             l a s t C o m m o n S e p   =   0 ;   
         / /   G e n e r a t e   t h e   r e l a t i v e   p a t h   b a s e d   o n   t h e   p a t h   d i f f e r e n c e   b e t w e e n   ` t o `   a n d   
         / /   ` f r o m `   
         f o r   ( i   =   f r o m S t a r t   +   l a s t C o m m o n S e p   +   1 ;   i   < =   f r o m E n d ;   + + i )   {   
             i f   ( i   = = =   f r o m E n d   | |   f r o m . c h a r C o d e A t ( i )   = = =   9 2 / * \ * / )   {   
                 i f   ( o u t . l e n g t h   = = =   0 )   
                     o u t   + =   ' . . ' ;   
                 e l s e   
                     o u t   + =   ' \ \ . . ' ;   
             }   
         }   
   
         / /   L a s t l y ,   a p p e n d   t h e   r e s t   o f   t h e   d e s t i n a t i o n   ( ` t o ` )   p a t h   t h a t   c o m e s   a f t e r   
         / /   t h e   c o m m o n   p a t h   p a r t s   
         i f   ( o u t . l e n g t h   >   0 )   
             r e t u r n   o u t   +   t o O r i g . s l i c e ( t o S t a r t   +   l a s t C o m m o n S e p ,   t o E n d ) ;   
         e l s e   {   
             t o S t a r t   + =   l a s t C o m m o n S e p ;   
             i f   ( t o O r i g . c h a r C o d e A t ( t o S t a r t )   = = =   9 2 / * \ * / )   
                 + + t o S t a r t ;   
             r e t u r n   t o O r i g . s l i c e ( t o S t a r t ,   t o E n d ) ;   
         }   
     } ,   
   
   
     _ m a k e L o n g :   f u n c t i o n   _ m a k e L o n g ( p a t h )   {   
         / /   N o t e :   t h i s   w i l l   * p r o b a b l y *   t h r o w   s o m e w h e r e .   
         i f   ( t y p e o f   p a t h   ! = =   ' s t r i n g ' )   
             r e t u r n   p a t h ;   
   
         i f   ( p a t h . l e n g t h   = = =   0 )   {   
             r e t u r n   ' ' ;   
         }   
   
         c o n s t   r e s o l v e d P a t h   =   w i n 3 2 . r e s o l v e ( p a t h ) ;   
   
         i f   ( r e s o l v e d P a t h . l e n g t h   > =   3 )   {   
             v a r   c o d e   =   r e s o l v e d P a t h . c h a r C o d e A t ( 0 ) ;   
             i f   ( c o d e   = = =   9 2 / * \ * / )   {   
                 / /   P o s s i b l e   U N C   r o o t   
   
                 i f   ( r e s o l v e d P a t h . c h a r C o d e A t ( 1 )   = = =   9 2 / * \ * / )   {   
                     c o d e   =   r e s o l v e d P a t h . c h a r C o d e A t ( 2 ) ;   
                     i f   ( c o d e   ! = =   6 3 / * ? * /   & &   c o d e   ! = =   4 6 / * . * / )   {   
                         / /   M a t c h e d   n o n - l o n g   U N C   r o o t ,   c o n v e r t   t h e   p a t h   t o   a   l o n g   U N C   p a t h   
                         r e t u r n   ' \ \ \ \ ? \ \ U N C \ \ '   +   r e s o l v e d P a t h . s l i c e ( 2 ) ;   
                     }   
                 }   
             }   e l s e   i f   ( ( c o d e   > =   6 5 / * A * /   & &   c o d e   < =   9 0 / * Z * / )   | |   
                                   ( c o d e   > =   9 7 / * a * /   & &   c o d e   < =   1 2 2 / * z * / ) )   {   
                 / /   P o s s i b l e   d e v i c e   r o o t   
   
                 i f   ( r e s o l v e d P a t h . c h a r C o d e A t ( 1 )   = = =   5 8 / * : * /   & &   
                         r e s o l v e d P a t h . c h a r C o d e A t ( 2 )   = = =   9 2 / * \ * / )   {   
                     / /   M a t c h e d   d e v i c e   r o o t ,   c o n v e r t   t h e   p a t h   t o   a   l o n g   U N C   p a t h   
                     r e t u r n   ' \ \ \ \ ? \ \ '   +   r e s o l v e d P a t h ;   
                 }   
             }   
         }   
   
         r e t u r n   p a t h ;   
     } ,   
   
   
     d i r n a m e :   f u n c t i o n   d i r n a m e ( p a t h )   {   
         a s s e r t P a t h ( p a t h ) ;   
         c o n s t   l e n   =   p a t h . l e n g t h ;   
         i f   ( l e n   = = =   0 )   
             r e t u r n   ' . ' ;   
         v a r   r o o t E n d   =   - 1 ;   
         v a r   e n d   =   - 1 ;   
         v a r   m a t c h e d S l a s h   =   t r u e ;   
         v a r   o f f s e t   =   0 ;   
         v a r   c o d e   =   p a t h . c h a r C o d e A t ( 0 ) ;   
   
         / /   T r y   t o   m a t c h   a   r o o t   
         i f   ( l e n   >   1 )   {   
             i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                 / /   P o s s i b l e   U N C   r o o t   
   
                 r o o t E n d   =   o f f s e t   =   1 ;   
   
                 c o d e   =   p a t h . c h a r C o d e A t ( 1 ) ;   
                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                     / /   M a t c h e d   d o u b l e   p a t h   s e p a r a t o r   a t   b e g i n n i n g   
                     v a r   j   =   2 ;   
                     v a r   l a s t   =   j ;   
                     / /   M a t c h   1   o r   m o r e   n o n - p a t h   s e p a r a t o r s   
                     f o r   ( ;   j   <   l e n ;   + + j )   {   
                         c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                         i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                             b r e a k ;   
                     }   
                     i f   ( j   <   l e n   & &   j   ! = =   l a s t )   {   
                         / /   M a t c h e d !   
                         l a s t   =   j ;   
                         / /   M a t c h   1   o r   m o r e   p a t h   s e p a r a t o r s   
                         f o r   ( ;   j   <   l e n ;   + + j )   {   
                             c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                             i f   ( c o d e   ! = =   4 7 / * / * /   & &   c o d e   ! = =   9 2 / * \ * / )   
                                 b r e a k ;   
                         }   
                         i f   ( j   <   l e n   & &   j   ! = =   l a s t )   {   
                             / /   M a t c h e d !   
                             l a s t   =   j ;   
                             / /   M a t c h   1   o r   m o r e   n o n - p a t h   s e p a r a t o r s   
                             f o r   ( ;   j   <   l e n ;   + + j )   {   
                                 c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                                     b r e a k ;   
                             }   
                             i f   ( j   = = =   l e n )   {   
                                 / /   W e   m a t c h e d   a   U N C   r o o t   o n l y   
                                 r e t u r n   p a t h ;   
                             }   
                             i f   ( j   ! = =   l a s t )   {   
                                 / /   W e   m a t c h e d   a   U N C   r o o t   w i t h   l e f t o v e r s   
   
                                 / /   O f f s e t   b y   1   t o   i n c l u d e   t h e   s e p a r a t o r   a f t e r   t h e   U N C   r o o t   t o   
                                 / /   t r e a t   i t   a s   a   " n o r m a l   r o o t "   o n   t o p   o f   a   ( U N C )   r o o t   
                                 r o o t E n d   =   o f f s e t   =   j   +   1 ;   
                             }   
                         }   
                     }   
                 }   
             }   e l s e   i f   ( ( c o d e   > =   6 5 / * A * /   & &   c o d e   < =   9 0 / * Z * / )   | |   
                                   ( c o d e   > =   9 7 / * a * /   & &   c o d e   < =   1 2 2 / * z * / ) )   {   
                 / /   P o s s i b l e   d e v i c e   r o o t   
   
                 c o d e   =   p a t h . c h a r C o d e A t ( 1 ) ;   
                 i f   ( p a t h . c h a r C o d e A t ( 1 )   = = =   5 8 / * : * / )   {   
                     r o o t E n d   =   o f f s e t   =   2 ;   
                     i f   ( l e n   >   2 )   {   
                         c o d e   =   p a t h . c h a r C o d e A t ( 2 ) ;   
                         i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                             r o o t E n d   =   o f f s e t   =   3 ;   
                     }   
                 }   
             }   
         }   e l s e   i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
             r e t u r n   p a t h [ 0 ] ;   
         }   
   
         f o r   ( v a r   i   =   l e n   -   1 ;   i   > =   o f f s e t ;   - - i )   {   
             c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
             i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                 i f   ( ! m a t c h e d S l a s h )   {   
                     e n d   =   i ;   
                     b r e a k ;   
                 }   
             }   e l s e   {   
                 / /   W e   s a w   t h e   f i r s t   n o n - p a t h   s e p a r a t o r   
                 m a t c h e d S l a s h   =   f a l s e ;   
             }   
         }   
   
         i f   ( e n d   = = =   - 1 )   {   
             i f   ( r o o t E n d   = = =   - 1 )   
                 r e t u r n   ' . ' ;   
             e l s e   
                 e n d   =   r o o t E n d ;   
         }   
         r e t u r n   p a t h . s l i c e ( 0 ,   e n d ) ;   
     } ,   
   
   
     b a s e n a m e :   f u n c t i o n   b a s e n a m e ( p a t h ,   e x t )   {   
         i f   ( e x t   ! = =   u n d e f i n e d   & &   t y p e o f   e x t   ! = =   ' s t r i n g ' )   
             t h r o w   n e w   T y p e E r r o r ( ' " e x t "   a r g u m e n t   m u s t   b e   a   s t r i n g ' ) ;   
         a s s e r t P a t h ( p a t h ) ;   
         v a r   s t a r t   =   0 ;   
         v a r   e n d   =   - 1 ;   
         v a r   m a t c h e d S l a s h   =   t r u e ;   
         v a r   i ;   
   
         / /   C h e c k   f o r   a   d r i v e   l e t t e r   p r e f i x   s o   a s   n o t   t o   m i s t a k e   t h e   f o l l o w i n g   
         / /   p a t h   s e p a r a t o r   a s   a n   e x t r a   s e p a r a t o r   a t   t h e   e n d   o f   t h e   p a t h   t h a t   c a n   b e   
         / /   d i s r e g a r d e d   
         i f   ( p a t h . l e n g t h   > =   2 )   {   
             c o n s t   d r i v e   =   p a t h . c h a r C o d e A t ( 0 ) ;   
             i f   ( ( d r i v e   > =   6 5 / * A * /   & &   d r i v e   < =   9 0 / * Z * / )   | |   
                     ( d r i v e   > =   9 7 / * a * /   & &   d r i v e   < =   1 2 2 / * z * / ) )   {   
                 i f   ( p a t h . c h a r C o d e A t ( 1 )   = = =   5 8 / * : * / )   
                     s t a r t   =   2 ;   
             }   
         }   
   
         i f   ( e x t   ! = =   u n d e f i n e d   & &   e x t . l e n g t h   >   0   & &   e x t . l e n g t h   < =   p a t h . l e n g t h )   {   
             i f   ( e x t . l e n g t h   = = =   p a t h . l e n g t h   & &   e x t   = = =   p a t h )   
                 r e t u r n   ' ' ;   
             v a r   e x t I d x   =   e x t . l e n g t h   -   1 ;   
             v a r   f i r s t N o n S l a s h E n d   =   - 1 ;   
             f o r   ( i   =   p a t h . l e n g t h   -   1 ;   i   > =   s t a r t ;   - - i )   {   
                 c o n s t   c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                     / /   I f   w e   r e a c h e d   a   p a t h   s e p a r a t o r   t h a t   w a s   n o t   p a r t   o f   a   s e t   o f   p a t h   
                     / /   s e p a r a t o r s   a t   t h e   e n d   o f   t h e   s t r i n g ,   s t o p   n o w   
                     i f   ( ! m a t c h e d S l a s h )   {   
                         s t a r t   =   i   +   1 ;   
                         b r e a k ;   
                     }   
                 }   e l s e   {   
                     i f   ( f i r s t N o n S l a s h E n d   = = =   - 1 )   {   
                         / /   W e   s a w   t h e   f i r s t   n o n - p a t h   s e p a r a t o r ,   r e m e m b e r   t h i s   i n d e x   i n   c a s e   
                         / /   w e   n e e d   i t   i f   t h e   e x t e n s i o n   e n d s   u p   n o t   m a t c h i n g   
                         m a t c h e d S l a s h   =   f a l s e ;   
                         f i r s t N o n S l a s h E n d   =   i   +   1 ;   
                     }   
                     i f   ( e x t I d x   > =   0 )   {   
                         / /   T r y   t o   m a t c h   t h e   e x p l i c i t   e x t e n s i o n   
                         i f   ( c o d e   = = =   e x t . c h a r C o d e A t ( e x t I d x ) )   {   
                             i f   ( - - e x t I d x   = = =   - 1 )   {   
                                 / /   W e   m a t c h e d   t h e   e x t e n s i o n ,   s o   m a r k   t h i s   a s   t h e   e n d   o f   o u r   p a t h   
                                 / /   c o m p o n e n t   
                                 e n d   =   i ;   
                             }   
                         }   e l s e   {   
                             / /   E x t e n s i o n   d o e s   n o t   m a t c h ,   s o   o u r   r e s u l t   i s   t h e   e n t i r e   p a t h   
                             / /   c o m p o n e n t   
                             e x t I d x   =   - 1 ;   
                             e n d   =   f i r s t N o n S l a s h E n d ;   
                         }   
                     }   
                 }   
             }   
   
             i f   ( s t a r t   = = =   e n d )   
                 e n d   =   f i r s t N o n S l a s h E n d ;   
             e l s e   i f   ( e n d   = = =   - 1 )   
                 e n d   =   p a t h . l e n g t h ;   
             r e t u r n   p a t h . s l i c e ( s t a r t ,   e n d ) ;   
         }   e l s e   {   
             f o r   ( i   =   p a t h . l e n g t h   -   1 ;   i   > =   s t a r t ;   - - i )   {   
                 c o n s t   c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                     / /   I f   w e   r e a c h e d   a   p a t h   s e p a r a t o r   t h a t   w a s   n o t   p a r t   o f   a   s e t   o f   p a t h   
                     / /   s e p a r a t o r s   a t   t h e   e n d   o f   t h e   s t r i n g ,   s t o p   n o w   
                     i f   ( ! m a t c h e d S l a s h )   {   
                         s t a r t   =   i   +   1 ;   
                         b r e a k ;   
                     }   
                 }   e l s e   i f   ( e n d   = = =   - 1 )   {   
                     / /   W e   s a w   t h e   f i r s t   n o n - p a t h   s e p a r a t o r ,   m a r k   t h i s   a s   t h e   e n d   o f   o u r   
                     / /   p a t h   c o m p o n e n t   
                     m a t c h e d S l a s h   =   f a l s e ;   
                     e n d   =   i   +   1 ;   
                 }   
             }   
   
             i f   ( e n d   = = =   - 1 )   
                 r e t u r n   ' ' ;   
             r e t u r n   p a t h . s l i c e ( s t a r t ,   e n d ) ;   
         }   
     } ,   
   
   
     e x t n a m e :   f u n c t i o n   e x t n a m e ( p a t h )   {   
         a s s e r t P a t h ( p a t h ) ;   
         v a r   s t a r t D o t   =   - 1 ;   
         v a r   s t a r t P a r t   =   0 ;   
         v a r   e n d   =   - 1 ;   
         v a r   m a t c h e d S l a s h   =   t r u e ;   
         / /   T r a c k   t h e   s t a t e   o f   c h a r a c t e r s   ( i f   a n y )   w e   s e e   b e f o r e   o u r   f i r s t   d o t   a n d   
         / /   a f t e r   a n y   p a t h   s e p a r a t o r   w e   f i n d   
         v a r   p r e D o t S t a t e   =   0 ;   
         f o r   ( v a r   i   =   p a t h . l e n g t h   -   1 ;   i   > =   0 ;   - - i )   {   
             c o n s t   c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
             i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                 / /   I f   w e   r e a c h e d   a   p a t h   s e p a r a t o r   t h a t   w a s   n o t   p a r t   o f   a   s e t   o f   p a t h   
                 / /   s e p a r a t o r s   a t   t h e   e n d   o f   t h e   s t r i n g ,   s t o p   n o w   
                 i f   ( ! m a t c h e d S l a s h )   {   
                     s t a r t P a r t   =   i   +   1 ;   
                     b r e a k ;   
                 }   
                 c o n t i n u e ;   
             }   
             i f   ( e n d   = = =   - 1 )   {   
                 / /   W e   s a w   t h e   f i r s t   n o n - p a t h   s e p a r a t o r ,   m a r k   t h i s   a s   t h e   e n d   o f   o u r   
                 / /   e x t e n s i o n   
                 m a t c h e d S l a s h   =   f a l s e ;   
                 e n d   =   i   +   1 ;   
             }   
             i f   ( c o d e   = = =   4 6 / * . * / )   {   
                 / /   I f   t h i s   i s   o u r   f i r s t   d o t ,   m a r k   i t   a s   t h e   s t a r t   o f   o u r   e x t e n s i o n   
                 i f   ( s t a r t D o t   = = =   - 1 )   
                     s t a r t D o t   =   i ;   
                 e l s e   i f   ( p r e D o t S t a t e   ! = =   1 )   
                     p r e D o t S t a t e   =   1 ;   
             }   e l s e   i f   ( s t a r t D o t   ! = =   - 1 )   {   
                 / /   W e   s a w   a   n o n - d o t   a n d   n o n - p a t h   s e p a r a t o r   b e f o r e   o u r   d o t ,   s o   w e   s h o u l d   
                 / /   h a v e   a   g o o d   c h a n c e   a t   h a v i n g   a   n o n - e m p t y   e x t e n s i o n   
                 p r e D o t S t a t e   =   - 1 ;   
             }   
         }   
   
         i f   ( s t a r t D o t   = = =   - 1   | |   
                 e n d   = = =   - 1   | |   
                 / /   W e   s a w   a   n o n - d o t   c h a r a c t e r   i m m e d i a t e l y   b e f o r e   t h e   d o t   
                 p r e D o t S t a t e   = = =   0   | |   
                 / /   T h e   ( r i g h t - m o s t )   t r i m m e d   p a t h   c o m p o n e n t   i s   e x a c t l y   ' . . '   
                 ( p r e D o t S t a t e   = = =   1   & &   
                   s t a r t D o t   = = =   e n d   -   1   & &   
                   s t a r t D o t   = = =   s t a r t P a r t   +   1 ) )   {   
             r e t u r n   ' ' ;   
         }   
         r e t u r n   p a t h . s l i c e ( s t a r t D o t ,   e n d ) ;   
     } ,   
   
   
     f o r m a t :   f u n c t i o n   f o r m a t ( p a t h O b j e c t )   {   
         i f   ( p a t h O b j e c t   = = =   n u l l   | |   t y p e o f   p a t h O b j e c t   ! = =   ' o b j e c t ' )   {   
             t h r o w   n e w   T y p e E r r o r (   
                 ` P a r a m e t e r   " p a t h O b j e c t "   m u s t   b e   a n   o b j e c t ,   n o t   $ { t y p e o f   p a t h O b j e c t } `   
             ) ;   
         }   
         r e t u r n   _ f o r m a t ( ' \ \ ' ,   p a t h O b j e c t ) ;   
     } ,   
   
   
     p a r s e :   f u n c t i o n   p a r s e ( p a t h )   {   
         a s s e r t P a t h ( p a t h ) ;   
   
         v a r   r e t   =   {   r o o t :   ' ' ,   d i r :   ' ' ,   b a s e :   ' ' ,   e x t :   ' ' ,   n a m e :   ' '   } ;   
         i f   ( p a t h . l e n g t h   = = =   0 )   
             r e t u r n   r e t ;   
   
         v a r   l e n   =   p a t h . l e n g t h ;   
         v a r   r o o t E n d   =   0 ;   
         v a r   c o d e   =   p a t h . c h a r C o d e A t ( 0 ) ;   
         v a r   i s A b s o l u t e   =   f a l s e ;   
   
         / /   T r y   t o   m a t c h   a   r o o t   
         i f   ( l e n   >   1 )   {   
             i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                 / /   P o s s i b l e   U N C   r o o t   
   
                 i s A b s o l u t e   =   t r u e ;   
   
                 c o d e   =   p a t h . c h a r C o d e A t ( 1 ) ;   
                 r o o t E n d   =   1 ;   
                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                     / /   M a t c h e d   d o u b l e   p a t h   s e p a r a t o r   a t   b e g i n n i n g   
                     v a r   j   =   2 ;   
                     v a r   l a s t   =   j ;   
                     / /   M a t c h   1   o r   m o r e   n o n - p a t h   s e p a r a t o r s   
                     f o r   ( ;   j   <   l e n ;   + + j )   {   
                         c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                         i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                             b r e a k ;   
                     }   
                     i f   ( j   <   l e n   & &   j   ! = =   l a s t )   {   
                         / /   M a t c h e d !   
                         l a s t   =   j ;   
                         / /   M a t c h   1   o r   m o r e   p a t h   s e p a r a t o r s   
                         f o r   ( ;   j   <   l e n ;   + + j )   {   
                             c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                             i f   ( c o d e   ! = =   4 7 / * / * /   & &   c o d e   ! = =   9 2 / * \ * / )   
                                 b r e a k ;   
                         }   
                         i f   ( j   <   l e n   & &   j   ! = =   l a s t )   {   
                             / /   M a t c h e d !   
                             l a s t   =   j ;   
                             / /   M a t c h   1   o r   m o r e   n o n - p a t h   s e p a r a t o r s   
                             f o r   ( ;   j   <   l e n ;   + + j )   {   
                                 c o d e   =   p a t h . c h a r C o d e A t ( j ) ;   
                                 i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   
                                     b r e a k ;   
                             }   
                             i f   ( j   = = =   l e n )   {   
                                 / /   W e   m a t c h e d   a   U N C   r o o t   o n l y   
   
                                 r o o t E n d   =   j ;   
                             }   e l s e   i f   ( j   ! = =   l a s t )   {   
                                 / /   W e   m a t c h e d   a   U N C   r o o t   w i t h   l e f t o v e r s   
   
                                 r o o t E n d   =   j   +   1 ;   
                             }   
                         }   
                     }   
                 }   
             }   e l s e   i f   ( ( c o d e   > =   6 5 / * A * /   & &   c o d e   < =   9 0 / * Z * / )   | |   
                                   ( c o d e   > =   9 7 / * a * /   & &   c o d e   < =   1 2 2 / * z * / ) )   {   
                 / /   P o s s i b l e   d e v i c e   r o o t   
   
                 c o d e   =   p a t h . c h a r C o d e A t ( 1 ) ;   
                 i f   ( p a t h . c h a r C o d e A t ( 1 )   = = =   5 8 / * : * / )   {   
                     r o o t E n d   =   2 ;   
                     i f   ( l e n   >   2 )   {   
                         c o d e   =   p a t h . c h a r C o d e A t ( 2 ) ;   
                         i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                             i f   ( l e n   = = =   3 )   {   
                                 / /   ` p a t h `   c o n t a i n s   j u s t   a   d r i v e   r o o t ,   e x i t   e a r l y   t o   a v o i d   
                                 / /   u n n e c e s s a r y   w o r k   
                                 r e t . r o o t   =   r e t . d i r   =   p a t h . s l i c e ( 0 ,   3 ) ;   
                                 r e t u r n   r e t ;   
                             }   
                             i s A b s o l u t e   =   t r u e ;   
                             r o o t E n d   =   3 ;   
                         }   
                     }   e l s e   {   
                         / /   ` p a t h `   c o n t a i n s   j u s t   a   d r i v e   r o o t ,   e x i t   e a r l y   t o   a v o i d   
                         / /   u n n e c e s s a r y   w o r k   
                         r e t . r o o t   =   r e t . d i r   =   p a t h . s l i c e ( 0 ,   2 ) ;   
                         r e t u r n   r e t ;   
                     }   
                 }   
             }   
         }   e l s e   i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
             / /   ` p a t h `   c o n t a i n s   j u s t   a   p a t h   s e p a r a t o r ,   e x i t   e a r l y   t o   a v o i d   
             / /   u n n e c e s s a r y   w o r k   
             r e t . r o o t   =   r e t . d i r   =   p a t h [ 0 ] ;   
             r e t u r n   r e t ;   
         }   
   
         i f   ( r o o t E n d   >   0 )   
             r e t . r o o t   =   p a t h . s l i c e ( 0 ,   r o o t E n d ) ;   
   
         v a r   s t a r t D o t   =   - 1 ;   
         v a r   s t a r t P a r t   =   0 ;   
         v a r   e n d   =   - 1 ;   
         v a r   m a t c h e d S l a s h   =   t r u e ;   
         v a r   i   =   p a t h . l e n g t h   -   1 ;   
   
         / /   T r a c k   t h e   s t a t e   o f   c h a r a c t e r s   ( i f   a n y )   w e   s e e   b e f o r e   o u r   f i r s t   d o t   a n d   
         / /   a f t e r   a n y   p a t h   s e p a r a t o r   w e   f i n d   
         v a r   p r e D o t S t a t e   =   0 ;   
   
         / /   G e t   n o n - d i r   i n f o   
         f o r   ( ;   i   > =   r o o t E n d ;   - - i )   {   
             c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
             i f   ( c o d e   = = =   4 7 / * / * /   | |   c o d e   = = =   9 2 / * \ * / )   {   
                 / /   I f   w e   r e a c h e d   a   p a t h   s e p a r a t o r   t h a t   w a s   n o t   p a r t   o f   a   s e t   o f   p a t h   
                 / /   s e p a r a t o r s   a t   t h e   e n d   o f   t h e   s t r i n g ,   s t o p   n o w   
                 i f   ( ! m a t c h e d S l a s h )   {   
                     s t a r t P a r t   =   i   +   1 ;   
                     b r e a k ;   
                 }   
                 c o n t i n u e ;   
             }   
             i f   ( e n d   = = =   - 1 )   {   
                 / /   W e   s a w   t h e   f i r s t   n o n - p a t h   s e p a r a t o r ,   m a r k   t h i s   a s   t h e   e n d   o f   o u r   
                 / /   e x t e n s i o n   
                 m a t c h e d S l a s h   =   f a l s e ;   
                 e n d   =   i   +   1 ;   
             }   
             i f   ( c o d e   = = =   4 6 / * . * / )   {   
                 / /   I f   t h i s   i s   o u r   f i r s t   d o t ,   m a r k   i t   a s   t h e   s t a r t   o f   o u r   e x t e n s i o n   
                 i f   ( s t a r t D o t   = = =   - 1 )   
                     s t a r t D o t   =   i ;   
                 e l s e   i f   ( p r e D o t S t a t e   ! = =   1 )   
                     p r e D o t S t a t e   =   1 ;   
             }   e l s e   i f   ( s t a r t D o t   ! = =   - 1 )   {   
                 / /   W e   s a w   a   n o n - d o t   a n d   n o n - p a t h   s e p a r a t o r   b e f o r e   o u r   d o t ,   s o   w e   s h o u l d   
                 / /   h a v e   a   g o o d   c h a n c e   a t   h a v i n g   a   n o n - e m p t y   e x t e n s i o n   
                 p r e D o t S t a t e   =   - 1 ;   
             }   
         }   
   
         i f   ( s t a r t D o t   = = =   - 1   | |   
                 e n d   = = =   - 1   | |   
                 / /   W e   s a w   a   n o n - d o t   c h a r a c t e r   i m m e d i a t e l y   b e f o r e   t h e   d o t   
                 p r e D o t S t a t e   = = =   0   | |   
                 / /   T h e   ( r i g h t - m o s t )   t r i m m e d   p a t h   c o m p o n e n t   i s   e x a c t l y   ' . . '   
                 ( p r e D o t S t a t e   = = =   1   & &   
                   s t a r t D o t   = = =   e n d   -   1   & &   
                   s t a r t D o t   = = =   s t a r t P a r t   +   1 ) )   {   
             i f   ( e n d   ! = =   - 1 )   {   
                 i f   ( s t a r t P a r t   = = =   0   & &   i s A b s o l u t e )   
                     r e t . b a s e   =   r e t . n a m e   =   p a t h . s l i c e ( r o o t E n d ,   e n d ) ;   
                 e l s e   
                     r e t . b a s e   =   r e t . n a m e   =   p a t h . s l i c e ( s t a r t P a r t ,   e n d ) ;   
             }   
         }   e l s e   {   
             i f   ( s t a r t P a r t   = = =   0   & &   i s A b s o l u t e )   {   
                 r e t . n a m e   =   p a t h . s l i c e ( r o o t E n d ,   s t a r t D o t ) ;   
                 r e t . b a s e   =   p a t h . s l i c e ( r o o t E n d ,   e n d ) ;   
             }   e l s e   {   
                 r e t . n a m e   =   p a t h . s l i c e ( s t a r t P a r t ,   s t a r t D o t ) ;   
                 r e t . b a s e   =   p a t h . s l i c e ( s t a r t P a r t ,   e n d ) ;   
             }   
             r e t . e x t   =   p a t h . s l i c e ( s t a r t D o t ,   e n d ) ;   
         }   
   
         i f   ( s t a r t P a r t   >   0 )   
             r e t . d i r   =   p a t h . s l i c e ( 0 ,   s t a r t P a r t   -   1 ) ;   
         e l s e   i f   ( i s A b s o l u t e )   
             r e t . d i r   =   p a t h . s l i c e ( 0 ,   r o o t E n d ) ;   
   
         r e t u r n   r e t ;   
     } ,   
   
   
     s e p :   ' \ \ ' ,   
     d e l i m i t e r :   ' ; ' ,   
     w i n 3 2 :   n u l l ,   
     p o s i x :   n u l l   
 } ;   
   
   
 c o n s t   p o s i x   =   {   
     / /   p a t h . r e s o l v e ( [ f r o m   . . . ] ,   t o )   
     r e s o l v e :   f u n c t i o n   r e s o l v e ( )   {   
         v a r   r e s o l v e d P a t h   =   ' ' ;   
         v a r   r e s o l v e d A b s o l u t e   =   f a l s e ;   
         v a r   c w d ;   
   
         f o r   ( v a r   i   =   a r g u m e n t s . l e n g t h   -   1 ;   i   > =   - 1   & &   ! r e s o l v e d A b s o l u t e ;   i - - )   {   
             v a r   p a t h ;   
             i f   ( i   > =   0 )   
                 p a t h   =   a r g u m e n t s [ i ] ;   
             e l s e   {   
                 i f   ( c w d   = = =   u n d e f i n e d )   
                     c w d   =   p r o c e s s . c w d ( ) ;   
                 p a t h   =   c w d ;   
             }   
   
             a s s e r t P a t h ( p a t h ) ;   
   
             / /   S k i p   e m p t y   e n t r i e s   
             i f   ( p a t h . l e n g t h   = = =   0 )   {   
                 c o n t i n u e ;   
             }   
   
             r e s o l v e d P a t h   =   p a t h   +   ' / '   +   r e s o l v e d P a t h ;   
             r e s o l v e d A b s o l u t e   =   p a t h . c h a r C o d e A t ( 0 )   = = =   4 7 / * / * / ;   
         }   
   
         / /   A t   t h i s   p o i n t   t h e   p a t h   s h o u l d   b e   r e s o l v e d   t o   a   f u l l   a b s o l u t e   p a t h ,   b u t   
         / /   h a n d l e   r e l a t i v e   p a t h s   t o   b e   s a f e   ( m i g h t   h a p p e n   w h e n   p r o c e s s . c w d ( )   f a i l s )   
   
         / /   N o r m a l i z e   t h e   p a t h   
         r e s o l v e d P a t h   =   n o r m a l i z e S t r i n g P o s i x ( r e s o l v e d P a t h ,   ! r e s o l v e d A b s o l u t e ) ;   
   
         i f   ( r e s o l v e d A b s o l u t e )   {   
             i f   ( r e s o l v e d P a t h . l e n g t h   >   0 )   
                 r e t u r n   ' / '   +   r e s o l v e d P a t h ;   
             e l s e   
                 r e t u r n   ' / ' ;   
         }   e l s e   i f   ( r e s o l v e d P a t h . l e n g t h   >   0 )   {   
             r e t u r n   r e s o l v e d P a t h ;   
         }   e l s e   {   
             r e t u r n   ' . ' ;   
         }   
     } ,   
   
   
     n o r m a l i z e :   f u n c t i o n   n o r m a l i z e ( p a t h )   {   
         a s s e r t P a t h ( p a t h ) ;   
   
         i f   ( p a t h . l e n g t h   = = =   0 )   
             r e t u r n   ' . ' ;   
   
         c o n s t   i s A b s o l u t e   =   p a t h . c h a r C o d e A t ( 0 )   = = =   4 7 / * / * / ;   
         c o n s t   t r a i l i n g S e p a r a t o r   =   p a t h . c h a r C o d e A t ( p a t h . l e n g t h   -   1 )   = = =   4 7 / * / * / ;   
   
         / /   N o r m a l i z e   t h e   p a t h   
         p a t h   =   n o r m a l i z e S t r i n g P o s i x ( p a t h ,   ! i s A b s o l u t e ) ;   
   
         i f   ( p a t h . l e n g t h   = = =   0   & &   ! i s A b s o l u t e )   
             p a t h   =   ' . ' ;   
         i f   ( p a t h . l e n g t h   >   0   & &   t r a i l i n g S e p a r a t o r )   
             p a t h   + =   ' / ' ;   
   
         i f   ( i s A b s o l u t e )   
             r e t u r n   ' / '   +   p a t h ;   
         r e t u r n   p a t h ;   
     } ,   
   
   
     i s A b s o l u t e :   f u n c t i o n   i s A b s o l u t e ( p a t h )   {   
         a s s e r t P a t h ( p a t h ) ;   
         r e t u r n   p a t h . l e n g t h   >   0   & &   p a t h . c h a r C o d e A t ( 0 )   = = =   4 7 / * / * / ;   
     } ,   
   
   
     j o i n :   f u n c t i o n   j o i n ( )   {   
         i f   ( a r g u m e n t s . l e n g t h   = = =   0 )   
             r e t u r n   ' . ' ;   
         v a r   j o i n e d ;   
         f o r   ( v a r   i   =   0 ;   i   <   a r g u m e n t s . l e n g t h ;   + + i )   {   
             v a r   a r g   =   a r g u m e n t s [ i ] ;   
             a s s e r t P a t h ( a r g ) ;   
             i f   ( a r g . l e n g t h   >   0 )   {   
                 i f   ( j o i n e d   = = =   u n d e f i n e d )   
                     j o i n e d   =   a r g ;   
                 e l s e   
                     j o i n e d   + =   ' / '   +   a r g ;   
             }   
         }   
         i f   ( j o i n e d   = = =   u n d e f i n e d )   
             r e t u r n   ' . ' ;   
         r e t u r n   p o s i x . n o r m a l i z e ( j o i n e d ) ;   
     } ,   
   
   
     r e l a t i v e :   f u n c t i o n   r e l a t i v e ( f r o m ,   t o )   {   
         a s s e r t P a t h ( f r o m ) ;   
         a s s e r t P a t h ( t o ) ;   
   
         i f   ( f r o m   = = =   t o )   
             r e t u r n   ' ' ;   
   
         f r o m   =   p o s i x . r e s o l v e ( f r o m ) ;   
         t o   =   p o s i x . r e s o l v e ( t o ) ;   
   
         i f   ( f r o m   = = =   t o )   
             r e t u r n   ' ' ;   
   
         / /   T r i m   a n y   l e a d i n g   b a c k s l a s h e s   
         v a r   f r o m S t a r t   =   1 ;   
         f o r   ( ;   f r o m S t a r t   <   f r o m . l e n g t h ;   + + f r o m S t a r t )   {   
             i f   ( f r o m . c h a r C o d e A t ( f r o m S t a r t )   ! = =   4 7 / * / * / )   
                 b r e a k ;   
         }   
         v a r   f r o m E n d   =   f r o m . l e n g t h ;   
         v a r   f r o m L e n   =   ( f r o m E n d   -   f r o m S t a r t ) ;   
   
         / /   T r i m   a n y   l e a d i n g   b a c k s l a s h e s   
         v a r   t o S t a r t   =   1 ;   
         f o r   ( ;   t o S t a r t   <   t o . l e n g t h ;   + + t o S t a r t )   {   
             i f   ( t o . c h a r C o d e A t ( t o S t a r t )   ! = =   4 7 / * / * / )   
                 b r e a k ;   
         }   
         v a r   t o E n d   =   t o . l e n g t h ;   
         v a r   t o L e n   =   ( t o E n d   -   t o S t a r t ) ;   
   
         / /   C o m p a r e   p a t h s   t o   f i n d   t h e   l o n g e s t   c o m m o n   p a t h   f r o m   r o o t   
         v a r   l e n g t h   =   ( f r o m L e n   <   t o L e n   ?   f r o m L e n   :   t o L e n ) ;   
         v a r   l a s t C o m m o n S e p   =   - 1 ;   
         v a r   i   =   0 ;   
         f o r   ( ;   i   < =   l e n g t h ;   + + i )   {   
             i f   ( i   = = =   l e n g t h )   {   
                 i f   ( t o L e n   >   l e n g t h )   {   
                     i f   ( t o . c h a r C o d e A t ( t o S t a r t   +   i )   = = =   4 7 / * / * / )   {   
                         / /   W e   g e t   h e r e   i f   ` f r o m `   i s   t h e   e x a c t   b a s e   p a t h   f o r   ` t o ` .   
                         / /   F o r   e x a m p l e :   f r o m = ' / f o o / b a r ' ;   t o = ' / f o o / b a r / b a z '   
                         r e t u r n   t o . s l i c e ( t o S t a r t   +   i   +   1 ) ;   
                     }   e l s e   i f   ( i   = = =   0 )   {   
                         / /   W e   g e t   h e r e   i f   ` f r o m `   i s   t h e   r o o t   
                         / /   F o r   e x a m p l e :   f r o m = ' / ' ;   t o = ' / f o o '   
                         r e t u r n   t o . s l i c e ( t o S t a r t   +   i ) ;   
                     }   
                 }   e l s e   i f   ( f r o m L e n   >   l e n g t h )   {   
                     i f   ( f r o m . c h a r C o d e A t ( f r o m S t a r t   +   i )   = = =   4 7 / * / * / )   {   
                         / /   W e   g e t   h e r e   i f   ` t o `   i s   t h e   e x a c t   b a s e   p a t h   f o r   ` f r o m ` .   
                         / /   F o r   e x a m p l e :   f r o m = ' / f o o / b a r / b a z ' ;   t o = ' / f o o / b a r '   
                         l a s t C o m m o n S e p   =   i ;   
                     }   e l s e   i f   ( i   = = =   0 )   {   
                         / /   W e   g e t   h e r e   i f   ` t o `   i s   t h e   r o o t .   
                         / /   F o r   e x a m p l e :   f r o m = ' / f o o ' ;   t o = ' / '   
                         l a s t C o m m o n S e p   =   0 ;   
                     }   
                 }   
                 b r e a k ;   
             }   
             v a r   f r o m C o d e   =   f r o m . c h a r C o d e A t ( f r o m S t a r t   +   i ) ;   
             v a r   t o C o d e   =   t o . c h a r C o d e A t ( t o S t a r t   +   i ) ;   
             i f   ( f r o m C o d e   ! = =   t o C o d e )   
                 b r e a k ;   
             e l s e   i f   ( f r o m C o d e   = = =   4 7 / * / * / )   
                 l a s t C o m m o n S e p   =   i ;   
         }   
   
         v a r   o u t   =   ' ' ;   
         / /   G e n e r a t e   t h e   r e l a t i v e   p a t h   b a s e d   o n   t h e   p a t h   d i f f e r e n c e   b e t w e e n   ` t o `   
         / /   a n d   ` f r o m `   
         f o r   ( i   =   f r o m S t a r t   +   l a s t C o m m o n S e p   +   1 ;   i   < =   f r o m E n d ;   + + i )   {   
             i f   ( i   = = =   f r o m E n d   | |   f r o m . c h a r C o d e A t ( i )   = = =   4 7 / * / * / )   {   
                 i f   ( o u t . l e n g t h   = = =   0 )   
                     o u t   + =   ' . . ' ;   
                 e l s e   
                     o u t   + =   ' / . . ' ;   
             }   
         }   
   
         / /   L a s t l y ,   a p p e n d   t h e   r e s t   o f   t h e   d e s t i n a t i o n   ( ` t o ` )   p a t h   t h a t   c o m e s   a f t e r   
         / /   t h e   c o m m o n   p a t h   p a r t s   
         i f   ( o u t . l e n g t h   >   0 )   
             r e t u r n   o u t   +   t o . s l i c e ( t o S t a r t   +   l a s t C o m m o n S e p ) ;   
         e l s e   {   
             t o S t a r t   + =   l a s t C o m m o n S e p ;   
             i f   ( t o . c h a r C o d e A t ( t o S t a r t )   = = =   4 7 / * / * / )   
                 + + t o S t a r t ;   
             r e t u r n   t o . s l i c e ( t o S t a r t ) ;   
         }   
     } ,   
   
   
     _ m a k e L o n g :   f u n c t i o n   _ m a k e L o n g ( p a t h )   {   
         r e t u r n   p a t h ;   
     } ,   
   
   
     d i r n a m e :   f u n c t i o n   d i r n a m e ( p a t h )   {   
         a s s e r t P a t h ( p a t h ) ;   
         i f   ( p a t h . l e n g t h   = = =   0 )   
             r e t u r n   ' . ' ;   
         v a r   c o d e   =   p a t h . c h a r C o d e A t ( 0 ) ;   
         v a r   h a s R o o t   =   ( c o d e   = = =   4 7 / * / * / ) ;   
         v a r   e n d   =   - 1 ;   
         v a r   m a t c h e d S l a s h   =   t r u e ;   
         f o r   ( v a r   i   =   p a t h . l e n g t h   -   1 ;   i   > =   1 ;   - - i )   {   
             c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
             i f   ( c o d e   = = =   4 7 / * / * / )   {   
                 i f   ( ! m a t c h e d S l a s h )   {   
                     e n d   =   i ;   
                     b r e a k ;   
                 }   
             }   e l s e   {   
                 / /   W e   s a w   t h e   f i r s t   n o n - p a t h   s e p a r a t o r   
                 m a t c h e d S l a s h   =   f a l s e ;   
             }   
         }   
   
         i f   ( e n d   = = =   - 1 )   
             r e t u r n   h a s R o o t   ?   ' / '   :   ' . ' ;   
         i f   ( h a s R o o t   & &   e n d   = = =   1 )   
             r e t u r n   ' / / ' ;   
         r e t u r n   p a t h . s l i c e ( 0 ,   e n d ) ;   
     } ,   
   
   
     b a s e n a m e :   f u n c t i o n   b a s e n a m e ( p a t h ,   e x t )   {   
         i f   ( e x t   ! = =   u n d e f i n e d   & &   t y p e o f   e x t   ! = =   ' s t r i n g ' )   
             t h r o w   n e w   T y p e E r r o r ( ' " e x t "   a r g u m e n t   m u s t   b e   a   s t r i n g ' ) ;   
         a s s e r t P a t h ( p a t h ) ;   
   
         v a r   s t a r t   =   0 ;   
         v a r   e n d   =   - 1 ;   
         v a r   m a t c h e d S l a s h   =   t r u e ;   
         v a r   i ;   
   
         i f   ( e x t   ! = =   u n d e f i n e d   & &   e x t . l e n g t h   >   0   & &   e x t . l e n g t h   < =   p a t h . l e n g t h )   {   
             i f   ( e x t . l e n g t h   = = =   p a t h . l e n g t h   & &   e x t   = = =   p a t h )   
                 r e t u r n   ' ' ;   
             v a r   e x t I d x   =   e x t . l e n g t h   -   1 ;   
             v a r   f i r s t N o n S l a s h E n d   =   - 1 ;   
             f o r   ( i   =   p a t h . l e n g t h   -   1 ;   i   > =   0 ;   - - i )   {   
                 c o n s t   c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
                 i f   ( c o d e   = = =   4 7 / * / * / )   {   
                     / /   I f   w e   r e a c h e d   a   p a t h   s e p a r a t o r   t h a t   w a s   n o t   p a r t   o f   a   s e t   o f   p a t h   
                     / /   s e p a r a t o r s   a t   t h e   e n d   o f   t h e   s t r i n g ,   s t o p   n o w   
                     i f   ( ! m a t c h e d S l a s h )   {   
                         s t a r t   =   i   +   1 ;   
                         b r e a k ;   
                     }   
                 }   e l s e   {   
                     i f   ( f i r s t N o n S l a s h E n d   = = =   - 1 )   {   
                         / /   W e   s a w   t h e   f i r s t   n o n - p a t h   s e p a r a t o r ,   r e m e m b e r   t h i s   i n d e x   i n   c a s e   
                         / /   w e   n e e d   i t   i f   t h e   e x t e n s i o n   e n d s   u p   n o t   m a t c h i n g   
                         m a t c h e d S l a s h   =   f a l s e ;   
                         f i r s t N o n S l a s h E n d   =   i   +   1 ;   
                     }   
                     i f   ( e x t I d x   > =   0 )   {   
                         / /   T r y   t o   m a t c h   t h e   e x p l i c i t   e x t e n s i o n   
                         i f   ( c o d e   = = =   e x t . c h a r C o d e A t ( e x t I d x ) )   {   
                             i f   ( - - e x t I d x   = = =   - 1 )   {   
                                 / /   W e   m a t c h e d   t h e   e x t e n s i o n ,   s o   m a r k   t h i s   a s   t h e   e n d   o f   o u r   p a t h   
                                 / /   c o m p o n e n t   
                                 e n d   =   i ;   
                             }   
                         }   e l s e   {   
                             / /   E x t e n s i o n   d o e s   n o t   m a t c h ,   s o   o u r   r e s u l t   i s   t h e   e n t i r e   p a t h   
                             / /   c o m p o n e n t   
                             e x t I d x   =   - 1 ;   
                             e n d   =   f i r s t N o n S l a s h E n d ;   
                         }   
                     }   
                 }   
             }   
   
             i f   ( s t a r t   = = =   e n d )   
                 e n d   =   f i r s t N o n S l a s h E n d ;   
             e l s e   i f   ( e n d   = = =   - 1 )   
                 e n d   =   p a t h . l e n g t h ;   
             r e t u r n   p a t h . s l i c e ( s t a r t ,   e n d ) ;   
         }   e l s e   {   
             f o r   ( i   =   p a t h . l e n g t h   -   1 ;   i   > =   0 ;   - - i )   {   
                 i f   ( p a t h . c h a r C o d e A t ( i )   = = =   4 7 / * / * / )   {   
                     / /   I f   w e   r e a c h e d   a   p a t h   s e p a r a t o r   t h a t   w a s   n o t   p a r t   o f   a   s e t   o f   p a t h   
                     / /   s e p a r a t o r s   a t   t h e   e n d   o f   t h e   s t r i n g ,   s t o p   n o w   
                     i f   ( ! m a t c h e d S l a s h )   {   
                         s t a r t   =   i   +   1 ;   
                         b r e a k ;   
                     }   
                 }   e l s e   i f   ( e n d   = = =   - 1 )   {   
                     / /   W e   s a w   t h e   f i r s t   n o n - p a t h   s e p a r a t o r ,   m a r k   t h i s   a s   t h e   e n d   o f   o u r   
                     / /   p a t h   c o m p o n e n t   
                     m a t c h e d S l a s h   =   f a l s e ;   
                     e n d   =   i   +   1 ;   
                 }   
             }   
   
             i f   ( e n d   = = =   - 1 )   
                 r e t u r n   ' ' ;   
             r e t u r n   p a t h . s l i c e ( s t a r t ,   e n d ) ;   
         }   
     } ,   
   
   
     e x t n a m e :   f u n c t i o n   e x t n a m e ( p a t h )   {   
         a s s e r t P a t h ( p a t h ) ;   
         v a r   s t a r t D o t   =   - 1 ;   
         v a r   s t a r t P a r t   =   0 ;   
         v a r   e n d   =   - 1 ;   
         v a r   m a t c h e d S l a s h   =   t r u e ;   
         / /   T r a c k   t h e   s t a t e   o f   c h a r a c t e r s   ( i f   a n y )   w e   s e e   b e f o r e   o u r   f i r s t   d o t   a n d   
         / /   a f t e r   a n y   p a t h   s e p a r a t o r   w e   f i n d   
         v a r   p r e D o t S t a t e   =   0 ;   
         f o r   ( v a r   i   =   p a t h . l e n g t h   -   1 ;   i   > =   0 ;   - - i )   {   
             c o n s t   c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
             i f   ( c o d e   = = =   4 7 / * / * / )   {   
                 / /   I f   w e   r e a c h e d   a   p a t h   s e p a r a t o r   t h a t   w a s   n o t   p a r t   o f   a   s e t   o f   p a t h   
                 / /   s e p a r a t o r s   a t   t h e   e n d   o f   t h e   s t r i n g ,   s t o p   n o w   
                 i f   ( ! m a t c h e d S l a s h )   {   
                     s t a r t P a r t   =   i   +   1 ;   
                     b r e a k ;   
                 }   
                 c o n t i n u e ;   
             }   
             i f   ( e n d   = = =   - 1 )   {   
                 / /   W e   s a w   t h e   f i r s t   n o n - p a t h   s e p a r a t o r ,   m a r k   t h i s   a s   t h e   e n d   o f   o u r   
                 / /   e x t e n s i o n   
                 m a t c h e d S l a s h   =   f a l s e ;   
                 e n d   =   i   +   1 ;   
             }   
             i f   ( c o d e   = = =   4 6 / * . * / )   {   
                 / /   I f   t h i s   i s   o u r   f i r s t   d o t ,   m a r k   i t   a s   t h e   s t a r t   o f   o u r   e x t e n s i o n   
                 i f   ( s t a r t D o t   = = =   - 1 )   
                     s t a r t D o t   =   i ;   
                 e l s e   i f   ( p r e D o t S t a t e   ! = =   1 )   
                     p r e D o t S t a t e   =   1 ;   
             }   e l s e   i f   ( s t a r t D o t   ! = =   - 1 )   {   
                 / /   W e   s a w   a   n o n - d o t   a n d   n o n - p a t h   s e p a r a t o r   b e f o r e   o u r   d o t ,   s o   w e   s h o u l d   
                 / /   h a v e   a   g o o d   c h a n c e   a t   h a v i n g   a   n o n - e m p t y   e x t e n s i o n   
                 p r e D o t S t a t e   =   - 1 ;   
             }   
         }   
   
         i f   ( s t a r t D o t   = = =   - 1   | |   
                 e n d   = = =   - 1   | |   
                 / /   W e   s a w   a   n o n - d o t   c h a r a c t e r   i m m e d i a t e l y   b e f o r e   t h e   d o t   
                 p r e D o t S t a t e   = = =   0   | |   
                 / /   T h e   ( r i g h t - m o s t )   t r i m m e d   p a t h   c o m p o n e n t   i s   e x a c t l y   ' . . '   
                 ( p r e D o t S t a t e   = = =   1   & &   
                   s t a r t D o t   = = =   e n d   -   1   & &   
                   s t a r t D o t   = = =   s t a r t P a r t   +   1 ) )   {   
             r e t u r n   ' ' ;   
         }   
         r e t u r n   p a t h . s l i c e ( s t a r t D o t ,   e n d ) ;   
     } ,   
   
   
     f o r m a t :   f u n c t i o n   f o r m a t ( p a t h O b j e c t )   {   
         i f   ( p a t h O b j e c t   = = =   n u l l   | |   t y p e o f   p a t h O b j e c t   ! = =   ' o b j e c t ' )   {   
             t h r o w   n e w   T y p e E r r o r (   
                 ` P a r a m e t e r   " p a t h O b j e c t "   m u s t   b e   a n   o b j e c t ,   n o t   $ { t y p e o f   p a t h O b j e c t } `   
             ) ;   
         }   
         r e t u r n   _ f o r m a t ( ' / ' ,   p a t h O b j e c t ) ;   
     } ,   
   
   
     p a r s e :   f u n c t i o n   p a r s e ( p a t h )   {   
         a s s e r t P a t h ( p a t h ) ;   
   
         v a r   r e t   =   {   r o o t :   ' ' ,   d i r :   ' ' ,   b a s e :   ' ' ,   e x t :   ' ' ,   n a m e :   ' '   } ;   
         i f   ( p a t h . l e n g t h   = = =   0 )   
             r e t u r n   r e t ;   
         v a r   c o d e   =   p a t h . c h a r C o d e A t ( 0 ) ;   
         v a r   i s A b s o l u t e   =   ( c o d e   = = =   4 7 / * / * / ) ;   
         v a r   s t a r t ;   
         i f   ( i s A b s o l u t e )   {   
             r e t . r o o t   =   ' / ' ;   
             s t a r t   =   1 ;   
         }   e l s e   {   
             s t a r t   =   0 ;   
         }   
         v a r   s t a r t D o t   =   - 1 ;   
         v a r   s t a r t P a r t   =   0 ;   
         v a r   e n d   =   - 1 ;   
         v a r   m a t c h e d S l a s h   =   t r u e ;   
         v a r   i   =   p a t h . l e n g t h   -   1 ;   
   
         / /   T r a c k   t h e   s t a t e   o f   c h a r a c t e r s   ( i f   a n y )   w e   s e e   b e f o r e   o u r   f i r s t   d o t   a n d   
         / /   a f t e r   a n y   p a t h   s e p a r a t o r   w e   f i n d   
         v a r   p r e D o t S t a t e   =   0 ;   
   
         / /   G e t   n o n - d i r   i n f o   
         f o r   ( ;   i   > =   s t a r t ;   - - i )   {   
             c o d e   =   p a t h . c h a r C o d e A t ( i ) ;   
             i f   ( c o d e   = = =   4 7 / * / * / )   {   
                 / /   I f   w e   r e a c h e d   a   p a t h   s e p a r a t o r   t h a t   w a s   n o t   p a r t   o f   a   s e t   o f   p a t h   
                 / /   s e p a r a t o r s   a t   t h e   e n d   o f   t h e   s t r i n g ,   s t o p   n o w   
                 i f   ( ! m a t c h e d S l a s h )   {   
                     s t a r t P a r t   =   i   +   1 ;   
                     b r e a k ;   
                 }   
                 c o n t i n u e ;   
             }   
             i f   ( e n d   = = =   - 1 )   {   
                 / /   W e   s a w   t h e   f i r s t   n o n - p a t h   s e p a r a t o r ,   m a r k   t h i s   a s   t h e   e n d   o f   o u r   
                 / /   e x t e n s i o n   
                 m a t c h e d S l a s h   =   f a l s e ;   
                 e n d   =   i   +   1 ;   
             }   
             i f   ( c o d e   = = =   4 6 / * . * / )   {   
                 / /   I f   t h i s   i s   o u r   f i r s t   d o t ,   m a r k   i t   a s   t h e   s t a r t   o f   o u r   e x t e n s i o n   
                 i f   ( s t a r t D o t   = = =   - 1 )   
                     s t a r t D o t   =   i ;   
                 e l s e   i f   ( p r e D o t S t a t e   ! = =   1 )   
                     p r e D o t S t a t e   =   1 ;   
             }   e l s e   i f   ( s t a r t D o t   ! = =   - 1 )   {   
                 / /   W e   s a w   a   n o n - d o t   a n d   n o n - p a t h   s e p a r a t o r   b e f o r e   o u r   d o t ,   s o   w e   s h o u l d   
                 / /   h a v e   a   g o o d   c h a n c e   a t   h a v i n g   a   n o n - e m p t y   e x t e n s i o n   
                 p r e D o t S t a t e   =   - 1 ;   
             }   
         }   
   
         i f   ( s t a r t D o t   = = =   - 1   | |   
                 e n d   = = =   - 1   | |   
                 / /   W e   s a w   a   n o n - d o t   c h a r a c t e r   i m m e d i a t e l y   b e f o r e   t h e   d o t   
                 p r e D o t S t a t e   = = =   0   | |   
                 / /   T h e   ( r i g h t - m o s t )   t r i m m e d   p a t h   c o m p o n e n t   i s   e x a c t l y   ' . . '   
                 ( p r e D o t S t a t e   = = =   1   & &   
                   s t a r t D o t   = = =   e n d   -   1   & &   
                   s t a r t D o t   = = =   s t a r t P a r t   +   1 ) )   {   
             i f   ( e n d   ! = =   - 1 )   {   
                 i f   ( s t a r t P a r t   = = =   0   & &   i s A b s o l u t e )   
                     r e t . b a s e   =   r e t . n a m e   =   p a t h . s l i c e ( 1 ,   e n d ) ;   
                 e l s e   
                     r e t . b a s e   =   r e t . n a m e   =   p a t h . s l i c e ( s t a r t P a r t ,   e n d ) ;   
             }   
         }   e l s e   {   
             i f   ( s t a r t P a r t   = = =   0   & &   i s A b s o l u t e )   {   
                 r e t . n a m e   =   p a t h . s l i c e ( 1 ,   s t a r t D o t ) ;   
                 r e t . b a s e   =   p a t h . s l i c e ( 1 ,   e n d ) ;   
             }   e l s e   {   
                 r e t . n a m e   =   p a t h . s l i c e ( s t a r t P a r t ,   s t a r t D o t ) ;   
                 r e t . b a s e   =   p a t h . s l i c e ( s t a r t P a r t ,   e n d ) ;   
             }   
             r e t . e x t   =   p a t h . s l i c e ( s t a r t D o t ,   e n d ) ;   
         }   
   
         i f   ( s t a r t P a r t   >   0 )   
             r e t . d i r   =   p a t h . s l i c e ( 0 ,   s t a r t P a r t   -   1 ) ;   
         e l s e   i f   ( i s A b s o l u t e )   
             r e t . d i r   =   ' / ' ;   
   
         r e t u r n   r e t ;   
     } ,   
   
   
     s e p :   ' / ' ,   
     d e l i m i t e r :   ' : ' ,   
     w i n 3 2 :   n u l l ,   
     p o s i x :   n u l l   
 } ;   
   
   
 p o s i x . w i n 3 2   =   w i n 3 2 . w i n 3 2   =   w i n 3 2 ;   
 p o s i x . p o s i x   =   w i n 3 2 . p o s i x   =   p o s i x ;   
   
   
 i f   ( p r o c e s s . p l a t f o r m   = = =   ' w i n 3 2 ' )   
     m o d u l e . e x p o r t s   =   w i n 3 2 ;   
 e l s e   
     m o d u l e . e x p o r t s   =   p o s i x ;   
 
 } ) ; �:  h   ��
 N O D E _ M O D U L E S / P O L Y F I L L / W I N D O W T I M E R . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ��/ *   I m p l e m e n t a t i o n   o f   H T M L   T i m e r s   ( s e t I n t e r v a l / s e t T i m e o u t )   b a s e d   o n   s l e e p .   
   *   @ l i c e n s e   M I T   
   *   
   *   C o p y r i g h t   2 0 1 2   K e v i n   L o c k e   < k e v i n @ k e v i n l o c k e . n a m e >   
   *   M o d i f i e d   b y   U n i t y B a s e   t e a m   -   a d d e d   p r i o r i t y   t o   r e a l i s e   t h e   s e t I m m e d i a t e     
   * /   
 / * j s l i n t   b i t w i s e :   t r u e ,   e v i l :   t r u e   * /   
   
 / * *   
   *   A d d s   m e t h o d s   t o   i m p l e m e n t   t h e   H T M L 5   W i n d o w T i m e r s   i n t e r f a c e   o n   a   g i v e n   
   *   o b j e c t .   
   *   
   *   A d d s   t h e   f o l l o w i n g   m e t h o d s :   
   *   
   *     -   c l e a r I n t e r v a l   
   *     -   c l e a r T i m e o u t   
   *     -   s e t I n t e r v a l   
   *     -   s e t T i m e o u t <   
   *   
   *   S e e   h t t p : / / w w w . w h a t w g . o r g / s p e c s / w e b - a p p s / c u r r e n t - w o r k / m u l t i p a g e / t i m e r s . h t m l   
   *   f o r   t h e   c o m p l e t e   s p e c i f i c a t i o n   o f   t h e s e   m e t h o d s .   
   *   
   *   @ m o d u l e   W i n d o w T i m e r   
   * /   
 v a r   W i n d o w T i m e r   =   { } ;   
   
 / * *   
   *   @ m e t h o d   m a k e W i n d o w T i m e r   
   *   
   *   @ p a r a m   { O b j e c t }   t a r g e t   O b j e c t   t o   w h i c h   t h e   m e t h o d s   s h o u l d   b e   a d d e d .   
   *   @ p a r a m   { F u n c t i o n }   s l e e p   A   f u n c t i o n   w h i c h   s l e e p s   f o r   a   s p e c i f i e d   n u m b e r   o f   
   *           m i l l i s e c o n d s .   
   *   @ r e t u r n   { F u n c t i o n }   T h e   f u n c t i o n   w h i c h   r u n s   t h e   s c h e d u l e d   t i m e r s .   
   * /   
 f u n c t i o n   m a k e W i n d o w T i m e r ( t a r g e t ,   s l e e p )   {   
         " u s e   s t r i c t " ;   
     
         v a r   c o u n t e r   =   1 ,   
                 i n C a l l b a c k   =   f a l s e ,   
                 / /   M a p   h a n d l e   - >   t i m e r   
                 t i m e r s B y H a n d l e   =   { } ,   
                 / /   M i n - h e a p   o f   t i m e r s   b y   t i m e   t h e n   h a n d l e ,   i n d e x   0   u n u s e d   
                 t i m e r s B y T i m e   =   [   n u l l   ] ;   
     
         / * *   C o m p a r e s   t i m e r s   b a s e d   o n   s c h e d u l e d   t i m e   a n d   h a n d l e .   * /   
         f u n c t i o n   t i m e r C o m p a r e ( t 1 ,   t 2 )   {   
                 / /   N o t e :     O n l y   n e e d   l e s s - t h a n   f o r   o u r   u s e s   
                 r e t u r n   t 1 . p r i o r i t y   <   t 2 . p r i o r i t y   ?   - 1   :   ( t 1 . p r i o r i t y   = = =   t 2 . p r i o r i t y   ?   
                         ( t 1 . t i m e   <   t 2 . t i m e   ?   - 1   :   
                                 ( t 1 . t i m e   = = =   t 2 . t i m e   & &   t 1 . h a n d l e   <   t 2 . h a n d l e   ?   - 1   :   0 ) )   :   0 ) ;   
         }   
     
         / * *   F i x   t h e   h e a p   i n v a r i a n t   w h i c h   m a y   b e   v i o l a t e d   a t   a   g i v e n   i n d e x   * /   
         f u n c t i o n   h e a p F i x D o w n ( h e a p ,   i ,   l e s s c m p )   {   
                 v a r   j ,   t m p ;   
     
                 j   =   i   *   2 ;   
                 w h i l e   ( j   <   h e a p . l e n g t h )   {   
                         i f   ( j   +   1   <   h e a p . l e n g t h   & &   
                                         l e s s c m p ( h e a p [ j   +   1 ] ,   h e a p [ j ] )   <   0 )   {   
                                 j   =   j   +   1 ;   
                         }   
     
                         i f   ( l e s s c m p ( h e a p [ i ] ,   h e a p [ j ] )   <   0 )   {   
                                 b r e a k ;   
                         }   
     
                         t m p   =   h e a p [ j ] ;   
                         h e a p [ j ]   =   h e a p [ i ] ;   
                         h e a p [ i ]   =   t m p ;   
                         i   =   j ;   
                         j   =   i   *   2 ;   
                 }   
         }   
     
         / * *   F i x   t h e   h e a p   i n v a r i a n t   w h i c h   m a y   b e   v i o l a t e d   a t   a   g i v e n   i n d e x   * /   
         f u n c t i o n   h e a p F i x U p ( h e a p ,   i ,   l e s s c m p )   {   
                 v a r   j ,   t m p ;   
                 w h i l e   ( i   >   1 )   {   
                         j   =   i   > >   1 ;           / /   I n t e g e r   d i v   b y   2   
     
                         i f   ( l e s s c m p ( h e a p [ j ] ,   h e a p [ i ] )   <   0 )   {   
                                 b r e a k ;   
                         }   
     
                         t m p   =   h e a p [ j ] ;   
                         h e a p [ j ]   =   h e a p [ i ] ;   
                         h e a p [ i ]   =   t m p ;   
                         i   =   j ;   
                 }   
         }   
     
         / * *   R e m o v e   t h e   t i m e r   e l e m e n t   f r o m   t h e   h e a p   * /   
         f u n c t i o n   h e a p P o p ( h e a p ,   l e s s c m p ,   t i m e r )   {   
                 f o r   ( l e t   i n d e x   =   1 ;   i n d e x   <   h e a p . l e n g t h   -   1 ;   i n d e x + + )   {   
                         i f   ( h e a p [ i n d e x ]   & &   h e a p [ i n d e x ] . h a n d l e   = = =   t i m e r . h a n d l e )   {   
                                 h e a p [ i n d e x ]   =   h e a p [ h e a p . l e n g t h   -   1 ] ;   
                         }   
                 }   
                 / / h e a p [ 1 ]   =   h e a p [ h e a p . l e n g t h   -   1 ] ;   
                 h e a p . p o p ( ) ;   
                 h e a p F i x D o w n ( h e a p ,   1 ,   l e s s c m p ) ;   
         }   
     
         / * *   C r e a t e   a   t i m e r   a n d   s c h e d u l e   c o d e   t o   r u n   a t   a   g i v e n   t i m e   * /   
         f u n c t i o n   a d d T i m e r ( c o d e ,   d e l a y ,   r e p e a t ,   a r g s I f F n ,   p r i o r i t y )   {   
                 v a r   h a n d l e ,   t i m e r ;   
     
                 i f   ( t y p e o f   c o d e   ! = =   " f u n c t i o n " )   {   
                         c o d e   =   S t r i n g ( c o d e ) ;   
                         a r g s I f F n   =   n u l l ;   
                 }   
   
                 d e l a y   =   N u m b e r ( d e l a y )   | |   0 ;   
                 i f   ( i n C a l l b a c k )   {   
                         d e l a y   =   M a t h . m a x ( d e l a y ,   4 ) ;   
                 }   
                 / /   N o t e :     M u s t   s e t   h a n d l e   a f t e r   a r g u m e n t   c o n v e r s i o n   t o   p r o p e r l y   
                 / /   h a n d l e   c o n f o r m a n c e   t e s t   i n   H T M L 5   s p e c .   
                 h a n d l e   =   c o u n t e r ;   
                 c o u n t e r   + =   1 ;   
     
                 t i m e r   =   {   
                         a r g s :   a r g s I f F n ,   
                         c a n c e l :   f a l s e ,   
                         c o d e :   c o d e ,   
                         h a n d l e :   h a n d l e ,   
                         r e p e a t :   r e p e a t   ?   M a t h . m a x ( d e l a y ,   4 )   :   0 ,   
                         t i m e :   n e w   D a t e ( ) . g e t T i m e ( )   +   d e l a y ,   
                         p r i o r i t y :   p r i o r i t y   | |   0   
                 } ;   
   
                 t i m e r s B y H a n d l e [ h a n d l e ]   =   t i m e r ;   
                 t i m e r s B y T i m e . p u s h ( t i m e r ) ;   
                 h e a p F i x U p ( t i m e r s B y T i m e ,   t i m e r s B y T i m e . l e n g t h   -   1 ,   t i m e r C o m p a r e ) ;   
     
                 r e t u r n   h a n d l e ;   
         }   
     
         / * *   C a n c e l   a n   e x i s t i n g   t i m e r   * /   
         f u n c t i o n   c a n c e l T i m e r ( h a n d l e ,   r e p e a t )   {   
                 v a r   t i m e r ;   
     
                 i f   ( t i m e r s B y H a n d l e . h a s O w n P r o p e r t y ( h a n d l e ) )   {   
                         t i m e r   =   t i m e r s B y H a n d l e [ h a n d l e ] ;   
                         i f   ( r e p e a t   = = =   ( t i m e r . r e p e a t   >   0 ) )   {   
                                 t i m e r . c a n c e l   =   t r u e ;   
                         }   
                 }   
         }   
     
         f u n c t i o n   c l e a r I n t e r v a l ( h a n d l e )   {   
                 c a n c e l T i m e r ( h a n d l e ,   t r u e ) ;   
         }   
         t a r g e t . c l e a r I n t e r v a l   =   c l e a r I n t e r v a l ;   
     
         f u n c t i o n   c l e a r T i m e o u t ( h a n d l e )   {   
                 c a n c e l T i m e r ( h a n d l e ,   f a l s e ) ;   
         }   
         t a r g e t . c l e a r T i m e o u t   =   c l e a r T i m e o u t ;   
     
         f u n c t i o n   s e t I n t e r v a l ( c o d e ,   d e l a y )   {   
                 r e t u r n   a d d T i m e r (   
                         c o d e ,   
                         d e l a y ,   
                         t r u e ,   
                         A r r a y . p r o t o t y p e . s l i c e . c a l l ( a r g u m e n t s ,   2 )   
                 ) ;   
         }   
         t a r g e t . s e t I n t e r v a l   =   s e t I n t e r v a l ;   
     
         f u n c t i o n   s e t T i m e o u t ( c o d e ,   d e l a y )   {   
                 r e t u r n   a d d T i m e r (   
                         c o d e ,   
                         d e l a y ,   
                         f a l s e ,   
                         A r r a y . p r o t o t y p e . s l i c e . c a l l ( a r g u m e n t s ,   2 ) ,   
                         0   
                 ) ;   
         }   
         t a r g e t . s e t T i m e o u t   =   s e t T i m e o u t ;   
   
         f u n c t i o n   s e t T i m e o u t ( c o d e ,   d e l a y )   {   
                 r e t u r n   a d d T i m e r (   
                         c o d e ,   
                         d e l a y ,   
                         f a l s e ,   
                         A r r a y . p r o t o t y p e . s l i c e . c a l l ( a r g u m e n t s ,   2 ) ,   
                         0   
                 ) ;   
         }   
         t a r g e t . s e t T i m e o u t   =   s e t T i m e o u t ;   
   
         f u n c t i o n   s e t T i m e o u t W i t h P r i o r i t y ( c o d e ,   d e l a y ,   p r i o r i t y )   {   
                 r e t u r n   a d d T i m e r (   
                         c o d e ,   
                         d e l a y ,   
                         f a l s e ,   
                         A r r a y . p r o t o t y p e . s l i c e . c a l l ( a r g u m e n t s ,   3 ) ,   
                         p r i o r i t y   
                 ) ;   
         }   
         t i m e r L o o p . s e t T i m e o u t W i t h P r i o r i t y   =   s e t T i m e o u t W i t h P r i o r i t y ;   
   
         f u n c t i o n   t i m e r L o o p ( n o n b l o c k i n g )   {   
                 / /   o n   t h e   w a y   o u t ,   d o n ' t   b o t h e r .   i t   w o n ' t   g e t   f i r e d   a n y w a y .   
                 i f   ( p r o c e s s . _ e x i t i n g )   
                         r e t u r n ;   
   
                 v a r   n o w ,   t i m e r ;   
     
                 / /   N o t e :   i n d e x   0   u n u s e d   i n   t i m e r s B y T i m e   
                 w h i l e   ( t i m e r s B y T i m e . l e n g t h   >   1 )   {   
                         t i m e r   =   t i m e r s B y T i m e [ 1 ] ;   
     
                         i f   ( t i m e r . c a n c e l )   {   
                                 d e l e t e   t i m e r s B y H a n d l e [ t i m e r . h a n d l e ] ;   
                                 h e a p P o p ( t i m e r s B y T i m e ,   t i m e r C o m p a r e ,   t i m e r ) ;   
                         }   e l s e   {   
                                 n o w   =   n e w   D a t e ( ) . g e t T i m e ( ) ;   
                                 i f   ( t i m e r . t i m e   < =   n o w )   {   
                                         i n C a l l b a c k   =   t r u e ;   
                                         t r y   {   
                                                 i f   ( t y p e o f   t i m e r . c o d e   = = =   " f u n c t i o n " )   {   
                                                         t i m e r . c o d e . a p p l y ( u n d e f i n e d ,   t i m e r . a r g s ) ;   
                                                 }   e l s e   {   
                                                         e v a l ( t i m e r . c o d e ) ;   
                                                 }   
                                         }   f i n a l l y   {   
                                                 i n C a l l b a c k   =   f a l s e ;   
                                         }   
     
                                         i f   ( t i m e r . r e p e a t   >   0   & &   ! t i m e r . c a n c e l )   {   
                                                 t i m e r . t i m e   + =   t i m e r . r e p e a t ;   
                                                 h e a p F i x D o w n ( t i m e r s B y T i m e ,   1 ,   t i m e r C o m p a r e ) ;   
                                         }   e l s e   {   
                                                 d e l e t e   t i m e r s B y H a n d l e [ t i m e r . h a n d l e ] ;   
                                                 h e a p P o p ( t i m e r s B y T i m e ,   t i m e r C o m p a r e ,   t i m e r ) ;   
                                         }   
                                 }   e l s e   i f   ( ! n o n b l o c k i n g )   {   
                                         s l e e p ( t i m e r . t i m e   -   n o w ) ;   
                                 }   e l s e   {   
                                         r e t u r n   t r u e ;   
                                 }   
                         }   
                 }   
     
                 r e t u r n   f a l s e ;   
         } ;   
         r e t u r n   t i m e r L o o p ;   
 }   
     
 i f   ( t y p e o f   e x p o r t s   = = =   " o b j e c t " )   {   
         e x p o r t s . m a k e W i n d o w T i m e r   =   m a k e W i n d o w T i m e r ;   
 }   
   
 } ) ; s  P   ��
 N O D E _ M O D U L E S / P U N Y C O D E . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / * !   h t t p : / / m t h s . b e / p u n y c o d e   v 1 . 2 . 0   b y   @ m a t h i a s   * /   
 ; ( f u n c t i o n ( r o o t )   {   
   
 	 / * *   
 	   *   T h e   ` p u n y c o d e `   o b j e c t .   
 	   *   @ n a m e   p u n y c o d e   
 	   *   @ t y p e   O b j e c t   
 	   * /   
 	 v a r   p u n y c o d e ,   
   
 	 / * *   D e t e c t   f r e e   v a r i a b l e s   ` d e f i n e ` ,   ` e x p o r t s ` ,   ` m o d u l e `   a n d   ` r e q u i r e `   * /   
 	 f r e e D e f i n e   =   t y p e o f   d e f i n e   = =   ' f u n c t i o n '   & &   t y p e o f   d e f i n e . a m d   = =   ' o b j e c t '   & &   
 	 	 d e f i n e . a m d   & &   d e f i n e ,   
 	 f r e e E x p o r t s   =   t y p e o f   e x p o r t s   = =   ' o b j e c t '   & &   e x p o r t s ,   
 	 f r e e M o d u l e   =   t y p e o f   m o d u l e   = =   ' o b j e c t '   & &   m o d u l e ,   
 	 f r e e R e q u i r e   =   t y p e o f   r e q u i r e   = =   ' f u n c t i o n '   & &   r e q u i r e ,   
   
 	 / * *   H i g h e s t   p o s i t i v e   s i g n e d   3 2 - b i t   f l o a t   v a l u e   * /   
 	 m a x I n t   =   2 1 4 7 4 8 3 6 4 7 ,   / /   a k a .   0 x 7 F F F F F F F   o r   2 ^ 3 1 - 1   
   
 	 / * *   B o o t s t r i n g   p a r a m e t e r s   * /   
 	 b a s e   =   3 6 ,   
 	 t M i n   =   1 ,   
 	 t M a x   =   2 6 ,   
 	 s k e w   =   3 8 ,   
 	 d a m p   =   7 0 0 ,   
 	 i n i t i a l B i a s   =   7 2 ,   
 	 i n i t i a l N   =   1 2 8 ,   / /   0 x 8 0   
 	 d e l i m i t e r   =   ' - ' ,   / /   ' \ x 2 D '   
   
 	 / * *   R e g u l a r   e x p r e s s i o n s   * /   
 	 r e g e x P u n y c o d e   =   / ^ x n - - / ,   
 	 r e g e x N o n A S C I I   =   / [ ^   - ~ ] / ,   / /   u n p r i n t a b l e   A S C I I   c h a r s   +   n o n - A S C I I   c h a r s   
 	 r e g e x S e p a r a t o r s   =   / \ x 2 E | \ u 3 0 0 2 | \ u F F 0 E | \ u F F 6 1 / g ,   / /   R F C   3 4 9 0   s e p a r a t o r s   
   
 	 / * *   E r r o r   m e s s a g e s   * /   
 	 e r r o r s   =   {   
 	 	 ' o v e r f l o w ' :   ' O v e r f l o w :   i n p u t   n e e d s   w i d e r   i n t e g e r s   t o   p r o c e s s ' ,   
 	 	 ' n o t - b a s i c ' :   ' I l l e g a l   i n p u t   > =   0 x 8 0   ( n o t   a   b a s i c   c o d e   p o i n t ) ' ,   
 	 	 ' i n v a l i d - i n p u t ' :   ' I n v a l i d   i n p u t '   
 	 } ,   
   
 	 / * *   C o n v e n i e n c e   s h o r t c u t s   * /   
 	 b a s e M i n u s T M i n   =   b a s e   -   t M i n ,   
 	 f l o o r   =   M a t h . f l o o r ,   
 	 s t r i n g F r o m C h a r C o d e   =   S t r i n g . f r o m C h a r C o d e ,   
   
 	 / * *   T e m p o r a r y   v a r i a b l e   * /   
 	 k e y ;   
   
 	 / * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - * /   
   
 	 / * *   
 	   *   A   g e n e r i c   e r r o r   u t i l i t y   f u n c t i o n .   
 	   *   @ p r i v a t e   
 	   *   @ p a r a m   { S t r i n g }   t y p e   T h e   e r r o r   t y p e .   
 	   *   @ r e t u r n s   { E r r o r }   T h r o w s   a   ` R a n g e E r r o r `   w i t h   t h e   a p p l i c a b l e   e r r o r   m e s s a g e .   
 	   * /   
 	 f u n c t i o n   e r r o r ( t y p e )   {   
 	 	 t h r o w   R a n g e E r r o r ( e r r o r s [ t y p e ] ) ;   
 	 }   
   
 	 / * *   
 	   *   A   g e n e r i c   ` A r r a y # m a p `   u t i l i t y   f u n c t i o n .   
 	   *   @ p r i v a t e   
 	   *   @ p a r a m   { A r r a y }   a r r a y   T h e   a r r a y   t o   i t e r a t e   o v e r .   
 	   *   @ p a r a m   { F u n c t i o n }   c a l l b a c k   T h e   f u n c t i o n   t h a t   g e t s   c a l l e d   f o r   e v e r y   a r r a y   
 	   *   i t e m .   
 	   *   @ r e t u r n s   { A r r a y }   A   n e w   a r r a y   o f   v a l u e s   r e t u r n e d   b y   t h e   c a l l b a c k   f u n c t i o n .   
 	   * /   
 	 f u n c t i o n   m a p ( a r r a y ,   f n )   {   
 	 	 v a r   l e n g t h   =   a r r a y . l e n g t h ;   
 	 	 w h i l e   ( l e n g t h - - )   {   
 	 	 	 a r r a y [ l e n g t h ]   =   f n ( a r r a y [ l e n g t h ] ) ;   
 	 	 }   
 	 	 r e t u r n   a r r a y ;   
 	 }   
   
 	 / * *   
 	   *   A   s i m p l e   ` A r r a y # m a p ` - l i k e   w r a p p e r   t o   w o r k   w i t h   d o m a i n   n a m e   s t r i n g s .   
 	   *   @ p r i v a t e   
 	   *   @ p a r a m   { S t r i n g }   d o m a i n   T h e   d o m a i n   n a m e .   
 	   *   @ p a r a m   { F u n c t i o n }   c a l l b a c k   T h e   f u n c t i o n   t h a t   g e t s   c a l l e d   f o r   e v e r y   
 	   *   c h a r a c t e r .   
 	   *   @ r e t u r n s   { A r r a y }   A   n e w   s t r i n g   o f   c h a r a c t e r s   r e t u r n e d   b y   t h e   c a l l b a c k   
 	   *   f u n c t i o n .   
 	   * /   
 	 f u n c t i o n   m a p D o m a i n ( s t r i n g ,   f n )   {   
 	 	 r e t u r n   m a p ( s t r i n g . s p l i t ( r e g e x S e p a r a t o r s ) ,   f n ) . j o i n ( ' . ' ) ;   
 	 }   
   
 	 / * *   
 	   *   C r e a t e s   a n   a r r a y   c o n t a i n i n g   t h e   d e c i m a l   c o d e   p o i n t s   o f   e a c h   U n i c o d e   
 	   *   c h a r a c t e r   i n   t h e   s t r i n g .   W h i l e   J a v a S c r i p t   u s e s   U C S - 2   i n t e r n a l l y ,   
 	   *   t h i s   f u n c t i o n   w i l l   c o n v e r t   a   p a i r   o f   s u r r o g a t e   h a l v e s   ( e a c h   o f   w h i c h   
 	   *   U C S - 2   e x p o s e s   a s   s e p a r a t e   c h a r a c t e r s )   i n t o   a   s i n g l e   c o d e   p o i n t ,   
 	   *   m a t c h i n g   U T F - 1 6 .   
 	   *   @ s e e   ` p u n y c o d e . u c s 2 . e n c o d e `   
 	   *   @ s e e   < h t t p : / / m a t h i a s b y n e n s . b e / n o t e s / j a v a s c r i p t - e n c o d i n g >   
 	   *   @ m e m b e r O f   p u n y c o d e . u c s 2   
 	   *   @ n a m e   d e c o d e   
 	   *   @ p a r a m   { S t r i n g }   s t r i n g   T h e   U n i c o d e   i n p u t   s t r i n g   ( U C S - 2 ) .   
 	   *   @ r e t u r n s   { A r r a y }   T h e   n e w   a r r a y   o f   c o d e   p o i n t s .   
 	   * /   
 	 f u n c t i o n   u c s 2 d e c o d e ( s t r i n g )   {   
 	 	 v a r   o u t p u t   =   [ ] ,   
 	 	         c o u n t e r   =   0 ,   
 	 	         l e n g t h   =   s t r i n g . l e n g t h ,   
 	 	         v a l u e ,   
 	 	         e x t r a ;   
 	 	 w h i l e   ( c o u n t e r   <   l e n g t h )   {   
 	 	 	 v a l u e   =   s t r i n g . c h a r C o d e A t ( c o u n t e r + + ) ;   
 	 	 	 i f   ( ( v a l u e   &   0 x F 8 0 0 )   = =   0 x D 8 0 0   & &   c o u n t e r   <   l e n g t h )   {   
 	 	 	 	 / /   h i g h   s u r r o g a t e ,   a n d   t h e r e   i s   a   n e x t   c h a r a c t e r   
 	 	 	 	 e x t r a   =   s t r i n g . c h a r C o d e A t ( c o u n t e r + + ) ;   
 	 	 	 	 i f   ( ( e x t r a   &   0 x F C 0 0 )   = =   0 x D C 0 0 )   {   / /   l o w   s u r r o g a t e   
 	 	 	 	 	 o u t p u t . p u s h ( ( ( v a l u e   &   0 x 3 F F )   < <   1 0 )   +   ( e x t r a   &   0 x 3 F F )   +   0 x 1 0 0 0 0 ) ;   
 	 	 	 	 }   e l s e   {   
 	 	 	 	 	 o u t p u t . p u s h ( v a l u e ,   e x t r a ) ;   
 	 	 	 	 }   
 	 	 	 }   e l s e   {   
 	 	 	 	 o u t p u t . p u s h ( v a l u e ) ;   
 	 	 	 }   
 	 	 }   
 	 	 r e t u r n   o u t p u t ;   
 	 }   
   
 	 / * *   
 	   *   C r e a t e s   a   s t r i n g   b a s e d   o n   a n   a r r a y   o f   d e c i m a l   c o d e   p o i n t s .   
 	   *   @ s e e   ` p u n y c o d e . u c s 2 . d e c o d e `   
 	   *   @ m e m b e r O f   p u n y c o d e . u c s 2   
 	   *   @ n a m e   e n c o d e   
 	   *   @ p a r a m   { A r r a y }   c o d e P o i n t s   T h e   a r r a y   o f   d e c i m a l   c o d e   p o i n t s .   
 	   *   @ r e t u r n s   { S t r i n g }   T h e   n e w   U n i c o d e   s t r i n g   ( U C S - 2 ) .   
 	   * /   
 	 f u n c t i o n   u c s 2 e n c o d e ( a r r a y )   {   
 	 	 r e t u r n   m a p ( a r r a y ,   f u n c t i o n ( v a l u e )   {   
 	 	 	 v a r   o u t p u t   =   ' ' ;   
 	 	 	 i f   ( v a l u e   >   0 x F F F F )   {   
 	 	 	 	 v a l u e   - =   0 x 1 0 0 0 0 ;   
 	 	 	 	 o u t p u t   + =   s t r i n g F r o m C h a r C o d e ( v a l u e   > > >   1 0   &   0 x 3 F F   |   0 x D 8 0 0 ) ;   
 	 	 	 	 v a l u e   =   0 x D C 0 0   |   v a l u e   &   0 x 3 F F ;   
 	 	 	 }   
 	 	 	 o u t p u t   + =   s t r i n g F r o m C h a r C o d e ( v a l u e ) ;   
 	 	 	 r e t u r n   o u t p u t ;   
 	 	 } ) . j o i n ( ' ' ) ;   
 	 }   
   
 	 / * *   
 	   *   C o n v e r t s   a   b a s i c   c o d e   p o i n t   i n t o   a   d i g i t / i n t e g e r .   
 	   *   @ s e e   ` d i g i t T o B a s i c ( ) `   
 	   *   @ p r i v a t e   
 	   *   @ p a r a m   { N u m b e r }   c o d e P o i n t   T h e   b a s i c   ( d e c i m a l )   c o d e   p o i n t .   
 	   *   @ r e t u r n s   { N u m b e r }   T h e   n u m e r i c   v a l u e   o f   a   b a s i c   c o d e   p o i n t   ( f o r   u s e   i n   
 	   *   r e p r e s e n t i n g   i n t e g e r s )   i n   t h e   r a n g e   ` 0 `   t o   ` b a s e   -   1 ` ,   o r   ` b a s e `   i f   
 	   *   t h e   c o d e   p o i n t   d o e s   n o t   r e p r e s e n t   a   v a l u e .   
 	   * /   
 	 f u n c t i o n   b a s i c T o D i g i t ( c o d e P o i n t )   {   
 	 	 r e t u r n   c o d e P o i n t   -   4 8   <   1 0   
 	 	 	 ?   c o d e P o i n t   -   2 2   
 	 	 	 :   c o d e P o i n t   -   6 5   <   2 6   
 	 	 	 	 ?   c o d e P o i n t   -   6 5   
 	 	 	 	 :   c o d e P o i n t   -   9 7   <   2 6   
 	 	 	 	 	 ?   c o d e P o i n t   -   9 7   
 	 	 	 	 	 :   b a s e ;   
 	 }   
   
 	 / * *   
 	   *   C o n v e r t s   a   d i g i t / i n t e g e r   i n t o   a   b a s i c   c o d e   p o i n t .   
 	   *   @ s e e   ` b a s i c T o D i g i t ( ) `   
 	   *   @ p r i v a t e   
 	   *   @ p a r a m   { N u m b e r }   d i g i t   T h e   n u m e r i c   v a l u e   o f   a   b a s i c   c o d e   p o i n t .   
 	   *   @ r e t u r n s   { N u m b e r }   T h e   b a s i c   c o d e   p o i n t   w h o s e   v a l u e   ( w h e n   u s e d   f o r   
 	   *   r e p r e s e n t i n g   i n t e g e r s )   i s   ` d i g i t ` ,   w h i c h   n e e d s   t o   b e   i n   t h e   r a n g e   
 	   *   ` 0 `   t o   ` b a s e   -   1 ` .   I f   ` f l a g `   i s   n o n - z e r o ,   t h e   u p p e r c a s e   f o r m   i s   
 	   *   u s e d ;   e l s e ,   t h e   l o w e r c a s e   f o r m   i s   u s e d .   T h e   b e h a v i o r   i s   u n d e f i n e d   
 	   *   i f   f l a g   i s   n o n - z e r o   a n d   ` d i g i t `   h a s   n o   u p p e r c a s e   f o r m .   
 	   * /   
 	 f u n c t i o n   d i g i t T o B a s i c ( d i g i t ,   f l a g )   {   
 	 	 / /     0 . . 2 5   m a p   t o   A S C I I   a . . z   o r   A . . Z   
 	 	 / /   2 6 . . 3 5   m a p   t o   A S C I I   0 . . 9   
 	 	 r e t u r n   d i g i t   +   2 2   +   7 5   *   ( d i g i t   <   2 6 )   -   ( ( f l a g   ! =   0 )   < <   5 ) ;   
 	 }   
   
 	 / * *   
 	   *   B i a s   a d a p t a t i o n   f u n c t i o n   a s   p e r   s e c t i o n   3 . 4   o f   R F C   3 4 9 2 .   
 	   *   h t t p : / / t o o l s . i e t f . o r g / h t m l / r f c 3 4 9 2 # s e c t i o n - 3 . 4   
 	   *   @ p r i v a t e   
 	   * /   
 	 f u n c t i o n   a d a p t ( d e l t a ,   n u m P o i n t s ,   f i r s t T i m e )   {   
 	 	 v a r   k   =   0 ;   
 	 	 d e l t a   =   f i r s t T i m e   ?   f l o o r ( d e l t a   /   d a m p )   :   d e l t a   > >   1 ;   
 	 	 d e l t a   + =   f l o o r ( d e l t a   /   n u m P o i n t s ) ;   
 	 	 f o r   ( / *   n o   i n i t i a l i z a t i o n   * / ;   d e l t a   >   b a s e M i n u s T M i n   *   t M a x   > >   1 ;   k   + =   b a s e )   {   
 	 	 	 d e l t a   =   f l o o r ( d e l t a   /   b a s e M i n u s T M i n ) ;   
 	 	 }   
 	 	 r e t u r n   f l o o r ( k   +   ( b a s e M i n u s T M i n   +   1 )   *   d e l t a   /   ( d e l t a   +   s k e w ) ) ;   
 	 }   
   
 	 / * *   
 	   *   C o n v e r t s   a   b a s i c   c o d e   p o i n t   t o   l o w e r c a s e   i f   ` f l a g `   i s   f a l s y ,   o r   t o   
 	   *   u p p e r c a s e   i f   ` f l a g `   i s   t r u t h y .   T h e   c o d e   p o i n t   i s   u n c h a n g e d   i f   i t ' s   
 	   *   c a s e l e s s .   T h e   b e h a v i o r   i s   u n d e f i n e d   i f   ` c o d e P o i n t `   i s   n o t   a   b a s i c   c o d e   
 	   *   p o i n t .   
 	   *   @ p r i v a t e   
 	   *   @ p a r a m   { N u m b e r }   c o d e P o i n t   T h e   n u m e r i c   v a l u e   o f   a   b a s i c   c o d e   p o i n t .   
 	   *   @ r e t u r n s   { N u m b e r }   T h e   r e s u l t i n g   b a s i c   c o d e   p o i n t .   
 	   * /   
 	 f u n c t i o n   e n c o d e B a s i c ( c o d e P o i n t ,   f l a g )   {   
 	 	 c o d e P o i n t   - =   ( c o d e P o i n t   -   9 7   <   2 6 )   < <   5 ;   
 	 	 r e t u r n   c o d e P o i n t   +   ( ! f l a g   & &   c o d e P o i n t   -   6 5   <   2 6 )   < <   5 ;   
 	 }   
   
 	 / * *   
 	   *   C o n v e r t s   a   P u n y c o d e   s t r i n g   o f   A S C I I   c o d e   p o i n t s   t o   a   s t r i n g   o f   U n i c o d e   
 	   *   c o d e   p o i n t s .   
 	   *   @ m e m b e r O f   p u n y c o d e   
 	   *   @ p a r a m   { S t r i n g }   i n p u t   T h e   P u n y c o d e   s t r i n g   o f   A S C I I   c o d e   p o i n t s .   
 	   *   @ r e t u r n s   { S t r i n g }   T h e   r e s u l t i n g   s t r i n g   o f   U n i c o d e   c o d e   p o i n t s .   
 	   * /   
 	 f u n c t i o n   d e c o d e ( i n p u t )   {   
 	 	 / /   D o n ' t   u s e   U C S - 2   
 	 	 v a r   o u t p u t   =   [ ] ,   
 	 	         i n p u t L e n g t h   =   i n p u t . l e n g t h ,   
 	 	         o u t ,   
 	 	         i   =   0 ,   
 	 	         n   =   i n i t i a l N ,   
 	 	         b i a s   =   i n i t i a l B i a s ,   
 	 	         b a s i c ,   
 	 	         j ,   
 	 	         i n d e x ,   
 	 	         o l d i ,   
 	 	         w ,   
 	 	         k ,   
 	 	         d i g i t ,   
 	 	         t ,   
 	 	         l e n g t h ,   
 	 	         / * *   C a c h e d   c a l c u l a t i o n   r e s u l t s   * /   
 	 	         b a s e M i n u s T ;   
   
 	 	 / /   H a n d l e   t h e   b a s i c   c o d e   p o i n t s :   l e t   ` b a s i c `   b e   t h e   n u m b e r   o f   i n p u t   c o d e   
 	 	 / /   p o i n t s   b e f o r e   t h e   l a s t   d e l i m i t e r ,   o r   ` 0 `   i f   t h e r e   i s   n o n e ,   t h e n   c o p y   
 	 	 / /   t h e   f i r s t   b a s i c   c o d e   p o i n t s   t o   t h e   o u t p u t .   
   
 	 	 b a s i c   =   i n p u t . l a s t I n d e x O f ( d e l i m i t e r ) ;   
 	 	 i f   ( b a s i c   <   0 )   {   
 	 	 	 b a s i c   =   0 ;   
 	 	 }   
   
 	 	 f o r   ( j   =   0 ;   j   <   b a s i c ;   + + j )   {   
 	 	 	 / /   i f   i t ' s   n o t   a   b a s i c   c o d e   p o i n t   
 	 	 	 i f   ( i n p u t . c h a r C o d e A t ( j )   > =   0 x 8 0 )   {   
 	 	 	 	 e r r o r ( ' n o t - b a s i c ' ) ;   
 	 	 	 }   
 	 	 	 o u t p u t . p u s h ( i n p u t . c h a r C o d e A t ( j ) ) ;   
 	 	 }   
   
 	 	 / /   M a i n   d e c o d i n g   l o o p :   s t a r t   j u s t   a f t e r   t h e   l a s t   d e l i m i t e r   i f   a n y   b a s i c   c o d e   
 	 	 / /   p o i n t s   w e r e   c o p i e d ;   s t a r t   a t   t h e   b e g i n n i n g   o t h e r w i s e .   
   
 	 	 f o r   ( i n d e x   =   b a s i c   >   0   ?   b a s i c   +   1   :   0 ;   i n d e x   <   i n p u t L e n g t h ;   / *   n o   f i n a l   e x p r e s s i o n   * / )   {   
   
 	 	 	 / /   ` i n d e x `   i s   t h e   i n d e x   o f   t h e   n e x t   c h a r a c t e r   t o   b e   c o n s u m e d .   
 	 	 	 / /   D e c o d e   a   g e n e r a l i z e d   v a r i a b l e - l e n g t h   i n t e g e r   i n t o   ` d e l t a ` ,   
 	 	 	 / /   w h i c h   g e t s   a d d e d   t o   ` i ` .   T h e   o v e r f l o w   c h e c k i n g   i s   e a s i e r   
 	 	 	 / /   i f   w e   i n c r e a s e   ` i `   a s   w e   g o ,   t h e n   s u b t r a c t   o f f   i t s   s t a r t i n g   
 	 	 	 / /   v a l u e   a t   t h e   e n d   t o   o b t a i n   ` d e l t a ` .   
 	 	 	 f o r   ( o l d i   =   i ,   w   =   1 ,   k   =   b a s e ;   / *   n o   c o n d i t i o n   * / ;   k   + =   b a s e )   {   
   
 	 	 	 	 i f   ( i n d e x   > =   i n p u t L e n g t h )   {   
 	 	 	 	 	 e r r o r ( ' i n v a l i d - i n p u t ' ) ;   
 	 	 	 	 }   
   
 	 	 	 	 d i g i t   =   b a s i c T o D i g i t ( i n p u t . c h a r C o d e A t ( i n d e x + + ) ) ;   
   
 	 	 	 	 i f   ( d i g i t   > =   b a s e   | |   d i g i t   >   f l o o r ( ( m a x I n t   -   i )   /   w ) )   {   
 	 	 	 	 	 e r r o r ( ' o v e r f l o w ' ) ;   
 	 	 	 	 }   
   
 	 	 	 	 i   + =   d i g i t   *   w ;   
 	 	 	 	 t   =   k   < =   b i a s   ?   t M i n   :   ( k   > =   b i a s   +   t M a x   ?   t M a x   :   k   -   b i a s ) ;   
   
 	 	 	 	 i f   ( d i g i t   <   t )   {   
 	 	 	 	 	 b r e a k ;   
 	 	 	 	 }   
   
 	 	 	 	 b a s e M i n u s T   =   b a s e   -   t ;   
 	 	 	 	 i f   ( w   >   f l o o r ( m a x I n t   /   b a s e M i n u s T ) )   {   
 	 	 	 	 	 e r r o r ( ' o v e r f l o w ' ) ;   
 	 	 	 	 }   
   
 	 	 	 	 w   * =   b a s e M i n u s T ;   
   
 	 	 	 }   
   
 	 	 	 o u t   =   o u t p u t . l e n g t h   +   1 ;   
 	 	 	 b i a s   =   a d a p t ( i   -   o l d i ,   o u t ,   o l d i   = =   0 ) ;   
   
 	 	 	 / /   ` i `   w a s   s u p p o s e d   t o   w r a p   a r o u n d   f r o m   ` o u t `   t o   ` 0 ` ,   
 	 	 	 / /   i n c r e m e n t i n g   ` n `   e a c h   t i m e ,   s o   w e ' l l   f i x   t h a t   n o w :   
 	 	 	 i f   ( f l o o r ( i   /   o u t )   >   m a x I n t   -   n )   {   
 	 	 	 	 e r r o r ( ' o v e r f l o w ' ) ;   
 	 	 	 }   
   
 	 	 	 n   + =   f l o o r ( i   /   o u t ) ;   
 	 	 	 i   % =   o u t ;   
   
 	 	 	 / /   I n s e r t   ` n `   a t   p o s i t i o n   ` i `   o f   t h e   o u t p u t   
 	 	 	 o u t p u t . s p l i c e ( i + + ,   0 ,   n ) ;   
   
 	 	 }   
   
 	 	 r e t u r n   u c s 2 e n c o d e ( o u t p u t ) ;   
 	 }   
   
 	 / * *   
 	   *   C o n v e r t s   a   s t r i n g   o f   U n i c o d e   c o d e   p o i n t s   t o   a   P u n y c o d e   s t r i n g   o f   A S C I I   
 	   *   c o d e   p o i n t s .   
 	   *   @ m e m b e r O f   p u n y c o d e   
 	   *   @ p a r a m   { S t r i n g }   i n p u t   T h e   s t r i n g   o f   U n i c o d e   c o d e   p o i n t s .   
 	   *   @ r e t u r n s   { S t r i n g }   T h e   r e s u l t i n g   P u n y c o d e   s t r i n g   o f   A S C I I   c o d e   p o i n t s .   
 	   * /   
 	 f u n c t i o n   e n c o d e ( i n p u t )   {   
 	 	 v a r   n ,   
 	 	         d e l t a ,   
 	 	         h a n d l e d C P C o u n t ,   
 	 	         b a s i c L e n g t h ,   
 	 	         b i a s ,   
 	 	         j ,   
 	 	         m ,   
 	 	         q ,   
 	 	         k ,   
 	 	         t ,   
 	 	         c u r r e n t V a l u e ,   
 	 	         o u t p u t   =   [ ] ,   
 	 	         / * *   ` i n p u t L e n g t h `   w i l l   h o l d   t h e   n u m b e r   o f   c o d e   p o i n t s   i n   ` i n p u t ` .   * /   
 	 	         i n p u t L e n g t h ,   
 	 	         / * *   C a c h e d   c a l c u l a t i o n   r e s u l t s   * /   
 	 	         h a n d l e d C P C o u n t P l u s O n e ,   
 	 	         b a s e M i n u s T ,   
 	 	         q M i n u s T ;   
   
 	 	 / /   C o n v e r t   t h e   i n p u t   i n   U C S - 2   t o   U n i c o d e   
 	 	 i n p u t   =   u c s 2 d e c o d e ( i n p u t ) ;   
   
 	 	 / /   C a c h e   t h e   l e n g t h   
 	 	 i n p u t L e n g t h   =   i n p u t . l e n g t h ;   
   
 	 	 / /   I n i t i a l i z e   t h e   s t a t e   
 	 	 n   =   i n i t i a l N ;   
 	 	 d e l t a   =   0 ;   
 	 	 b i a s   =   i n i t i a l B i a s ;   
   
 	 	 / /   H a n d l e   t h e   b a s i c   c o d e   p o i n t s   
 	 	 f o r   ( j   =   0 ;   j   <   i n p u t L e n g t h ;   + + j )   {   
 	 	 	 c u r r e n t V a l u e   =   i n p u t [ j ] ;   
 	 	 	 i f   ( c u r r e n t V a l u e   <   0 x 8 0 )   {   
 	 	 	 	 o u t p u t . p u s h ( s t r i n g F r o m C h a r C o d e ( c u r r e n t V a l u e ) ) ;   
 	 	 	 }   
 	 	 }   
   
 	 	 h a n d l e d C P C o u n t   =   b a s i c L e n g t h   =   o u t p u t . l e n g t h ;   
   
 	 	 / /   ` h a n d l e d C P C o u n t `   i s   t h e   n u m b e r   o f   c o d e   p o i n t s   t h a t   h a v e   b e e n   h a n d l e d ;   
 	 	 / /   ` b a s i c L e n g t h `   i s   t h e   n u m b e r   o f   b a s i c   c o d e   p o i n t s .   
   
 	 	 / /   F i n i s h   t h e   b a s i c   s t r i n g   -   i f   i t   i s   n o t   e m p t y   -   w i t h   a   d e l i m i t e r   
 	 	 i f   ( b a s i c L e n g t h )   {   
 	 	 	 o u t p u t . p u s h ( d e l i m i t e r ) ;   
 	 	 }   
   
 	 	 / /   M a i n   e n c o d i n g   l o o p :   
 	 	 w h i l e   ( h a n d l e d C P C o u n t   <   i n p u t L e n g t h )   {   
   
 	 	 	 / /   A l l   n o n - b a s i c   c o d e   p o i n t s   <   n   h a v e   b e e n   h a n d l e d   a l r e a d y .   F i n d   t h e   n e x t   
 	 	 	 / /   l a r g e r   o n e :   
 	 	 	 f o r   ( m   =   m a x I n t ,   j   =   0 ;   j   <   i n p u t L e n g t h ;   + + j )   {   
 	 	 	 	 c u r r e n t V a l u e   =   i n p u t [ j ] ;   
 	 	 	 	 i f   ( c u r r e n t V a l u e   > =   n   & &   c u r r e n t V a l u e   <   m )   {   
 	 	 	 	 	 m   =   c u r r e n t V a l u e ;   
 	 	 	 	 }   
 	 	 	 }   
   
 	 	 	 / /   I n c r e a s e   ` d e l t a `   e n o u g h   t o   a d v a n c e   t h e   d e c o d e r ' s   < n , i >   s t a t e   t o   < m , 0 > ,   
 	 	 	 / /   b u t   g u a r d   a g a i n s t   o v e r f l o w   
 	 	 	 h a n d l e d C P C o u n t P l u s O n e   =   h a n d l e d C P C o u n t   +   1 ;   
 	 	 	 i f   ( m   -   n   >   f l o o r ( ( m a x I n t   -   d e l t a )   /   h a n d l e d C P C o u n t P l u s O n e ) )   {   
 	 	 	 	 e r r o r ( ' o v e r f l o w ' ) ;   
 	 	 	 }   
   
 	 	 	 d e l t a   + =   ( m   -   n )   *   h a n d l e d C P C o u n t P l u s O n e ;   
 	 	 	 n   =   m ;   
   
 	 	 	 f o r   ( j   =   0 ;   j   <   i n p u t L e n g t h ;   + + j )   {   
 	 	 	 	 c u r r e n t V a l u e   =   i n p u t [ j ] ;   
   
 	 	 	 	 i f   ( c u r r e n t V a l u e   <   n   & &   + + d e l t a   >   m a x I n t )   {   
 	 	 	 	 	 e r r o r ( ' o v e r f l o w ' ) ;   
 	 	 	 	 }   
   
 	 	 	 	 i f   ( c u r r e n t V a l u e   = =   n )   {   
 	 	 	 	 	 / /   R e p r e s e n t   d e l t a   a s   a   g e n e r a l i z e d   v a r i a b l e - l e n g t h   i n t e g e r   
 	 	 	 	 	 f o r   ( q   =   d e l t a ,   k   =   b a s e ;   / *   n o   c o n d i t i o n   * / ;   k   + =   b a s e )   {   
 	 	 	 	 	 	 t   =   k   < =   b i a s   ?   t M i n   :   ( k   > =   b i a s   +   t M a x   ?   t M a x   :   k   -   b i a s ) ;   
 	 	 	 	 	 	 i f   ( q   <   t )   {   
 	 	 	 	 	 	 	 b r e a k ;   
 	 	 	 	 	 	 }   
 	 	 	 	 	 	 q M i n u s T   =   q   -   t ;   
 	 	 	 	 	 	 b a s e M i n u s T   =   b a s e   -   t ;   
 	 	 	 	 	 	 o u t p u t . p u s h (   
 	 	 	 	 	 	 	 s t r i n g F r o m C h a r C o d e ( d i g i t T o B a s i c ( t   +   q M i n u s T   %   b a s e M i n u s T ,   0 ) )   
 	 	 	 	 	 	 ) ;   
 	 	 	 	 	 	 q   =   f l o o r ( q M i n u s T   /   b a s e M i n u s T ) ;   
 	 	 	 	 	 }   
   
 	 	 	 	 	 o u t p u t . p u s h ( s t r i n g F r o m C h a r C o d e ( d i g i t T o B a s i c ( q ,   0 ) ) ) ;   
 	 	 	 	 	 b i a s   =   a d a p t ( d e l t a ,   h a n d l e d C P C o u n t P l u s O n e ,   h a n d l e d C P C o u n t   = =   b a s i c L e n g t h ) ;   
 	 	 	 	 	 d e l t a   =   0 ;   
 	 	 	 	 	 + + h a n d l e d C P C o u n t ;   
 	 	 	 	 }   
 	 	 	 }   
   
 	 	 	 + + d e l t a ;   
 	 	 	 + + n ;   
   
 	 	 }   
 	 	 r e t u r n   o u t p u t . j o i n ( ' ' ) ;   
 	 }   
   
 	 / * *   
 	   *   C o n v e r t s   a   P u n y c o d e   s t r i n g   r e p r e s e n t i n g   a   d o m a i n   n a m e   t o   U n i c o d e .   O n l y   t h e   
 	   *   P u n y c o d e d   p a r t s   o f   t h e   d o m a i n   n a m e   w i l l   b e   c o n v e r t e d ,   i . e .   i t   d o e s n ' t   
 	   *   m a t t e r   i f   y o u   c a l l   i t   o n   a   s t r i n g   t h a t   h a s   a l r e a d y   b e e n   c o n v e r t e d   t o   
 	   *   U n i c o d e .   
 	   *   @ m e m b e r O f   p u n y c o d e   
 	   *   @ p a r a m   { S t r i n g }   d o m a i n   T h e   P u n y c o d e   d o m a i n   n a m e   t o   c o n v e r t   t o   U n i c o d e .   
 	   *   @ r e t u r n s   { S t r i n g }   T h e   U n i c o d e   r e p r e s e n t a t i o n   o f   t h e   g i v e n   P u n y c o d e   
 	   *   s t r i n g .   
 	   * /   
 	 f u n c t i o n   t o U n i c o d e ( d o m a i n )   {   
 	 	 r e t u r n   m a p D o m a i n ( d o m a i n ,   f u n c t i o n ( s t r i n g )   {   
 	 	 	 r e t u r n   r e g e x P u n y c o d e . t e s t ( s t r i n g )   
 	 	 	 	 ?   d e c o d e ( s t r i n g . s l i c e ( 4 ) . t o L o w e r C a s e ( ) )   
 	 	 	 	 :   s t r i n g ;   
 	 	 } ) ;   
 	 }   
   
 	 / * *   
 	   *   C o n v e r t s   a   U n i c o d e   s t r i n g   r e p r e s e n t i n g   a   d o m a i n   n a m e   t o   P u n y c o d e .   O n l y   t h e   
 	   *   n o n - A S C I I   p a r t s   o f   t h e   d o m a i n   n a m e   w i l l   b e   c o n v e r t e d ,   i . e .   i t   d o e s n ' t   
 	   *   m a t t e r   i f   y o u   c a l l   i t   w i t h   a   d o m a i n   t h a t ' s   a l r e a d y   i n   A S C I I .   
 	   *   @ m e m b e r O f   p u n y c o d e   
 	   *   @ p a r a m   { S t r i n g }   d o m a i n   T h e   d o m a i n   n a m e   t o   c o n v e r t ,   a s   a   U n i c o d e   s t r i n g .   
 	   *   @ r e t u r n s   { S t r i n g }   T h e   P u n y c o d e   r e p r e s e n t a t i o n   o f   t h e   g i v e n   d o m a i n   n a m e .   
 	   * /   
 	 f u n c t i o n   t o A S C I I ( d o m a i n )   {   
 	 	 r e t u r n   m a p D o m a i n ( d o m a i n ,   f u n c t i o n ( s t r i n g )   {   
 	 	 	 r e t u r n   r e g e x N o n A S C I I . t e s t ( s t r i n g )   
 	 	 	 	 ?   ' x n - - '   +   e n c o d e ( s t r i n g )   
 	 	 	 	 :   s t r i n g ;   
 	 	 } ) ;   
 	 }   
   
 	 / * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - * /   
   
 	 / * *   D e f i n e   t h e   p u b l i c   A P I   * /   
 	 p u n y c o d e   =   {   
 	 	 / * *   
 	 	   *   A   s t r i n g   r e p r e s e n t i n g   t h e   c u r r e n t   P u n y c o d e . j s   v e r s i o n   n u m b e r .   
 	 	   *   @ m e m b e r O f   p u n y c o d e   
 	 	   *   @ t y p e   S t r i n g   
 	 	   * /   
 	 	 ' v e r s i o n ' :   ' 1 . 2 . 0 ' ,   
 	 	 / * *   
 	 	   *   A n   o b j e c t   o f   m e t h o d s   t o   c o n v e r t   f r o m   J a v a S c r i p t ' s   i n t e r n a l   c h a r a c t e r   
 	 	   *   r e p r e s e n t a t i o n   ( U C S - 2 )   t o   d e c i m a l   U n i c o d e   c o d e   p o i n t s ,   a n d   b a c k .   
 	 	   *   @ s e e   < h t t p : / / m a t h i a s b y n e n s . b e / n o t e s / j a v a s c r i p t - e n c o d i n g >   
 	 	   *   @ m e m b e r O f   p u n y c o d e   
 	 	   *   @ t y p e   O b j e c t   
 	 	   * /   
 	 	 ' u c s 2 ' :   {   
 	 	 	 ' d e c o d e ' :   u c s 2 d e c o d e ,   
 	 	 	 ' e n c o d e ' :   u c s 2 e n c o d e   
 	 	 } ,   
 	 	 ' d e c o d e ' :   d e c o d e ,   
 	 	 ' e n c o d e ' :   e n c o d e ,   
 	 	 ' t o A S C I I ' :   t o A S C I I ,   
 	 	 ' t o U n i c o d e ' :   t o U n i c o d e   
 	 } ;   
   
 	 / * *   E x p o s e   ` p u n y c o d e `   * /   
 	 i f   ( f r e e E x p o r t s )   {   
 	 	 i f   ( f r e e M o d u l e   & &   f r e e M o d u l e . e x p o r t s   = =   f r e e E x p o r t s )   {   
 	 	 	 / /   i n   N o d e . j s   o r   R i n g o   0 . 8 +   
 	 	 	 f r e e M o d u l e . e x p o r t s   =   p u n y c o d e ;   
 	 	 }   e l s e   {   
 	 	 	 / /   i n   N a r w h a l   o r   R i n g o   0 . 7 -   
 	 	 	 f o r   ( k e y   i n   p u n y c o d e )   {   
 	 	 	 	 p u n y c o d e . h a s O w n P r o p e r t y ( k e y )   & &   ( f r e e E x p o r t s [ k e y ]   =   p u n y c o d e [ k e y ] ) ;   
 	 	 	 }   
 	 	 }   
 	 }   e l s e   i f   ( f r e e D e f i n e )   {   
 	 	 / /   v i a   c u r l . j s   o r   R e q u i r e J S   
 	 	 d e f i n e ( ' p u n y c o d e ' ,   p u n y c o d e ) ;   
 	 }   e l s e   {   
 	 	 / /   i n   a   b r o w s e r   o r   R h i n o   
 	 	 r o o t . p u n y c o d e   =   p u n y c o d e ;   
 	 }   
   
 } ( t h i s ) ) ;   
 
 } ) ; �6  T   ��
 N O D E _ M O D U L E S / Q U E R Y S T R I N G . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / /   C o p y r i g h t   J o y e n t ,   I n c .   a n d   o t h e r   N o d e   c o n t r i b u t o r s .   
 / /   M o d i f i e d   b y   U n i t y B a s e   c o r e   t e a m   t o   b e   c o m p a t i b l e   w i t h   S y N o d e   
 / /   Q u e r y   S t r i n g   U t i l i t i e s   
   
 / * *   
   *   @ m o d u l e   q u e r y s t r i n g   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 v a r   Q u e r y S t r i n g   =   e x p o r t s ;   
   
 / * *   
   *   T h i s   m o d u l e   p r o v i d e s   u t i l i t i e s   f o r   d e a l i n g   w i t h   q u e r y   s t r i n g s .   C a l l   ` r e q u i r e ( ' u r l ' ) `   t o   u s e   i t .   T h i s   i s   p o r t   o f   N o d e J S   < a   h r e f = " h t t p : / / n o d e j s . o r g / a p i / q u e r y s t r i n g . h t m l " > q u e r y s t r i n g < / a >   m o d u l e .   
   *   S m a l l   s a m p l e :   
   *   
   *                 v a r   q u e r y s t r i n g   =   r e q u i r e ( ' q u e r y s t r i n g ' ) ;   
   *                 q u e r y s t r i n g . s t r i n g i f y ( { p a r a m 1 :   ' v a l u e 1 ' ,   p a r a m 2 :   [ ' a r r 1 ' ,   ' a r r 2 ' ] ,   p a r a m E m p t y :   ' '   } )   
   *                 / /   r e t u r n s   ' p a r a m 1 = v a l u e 1 & p a r a m 2 = a r r 1 & p a r a m 2 = a r r 2 & p a r a m E m p t y = '   
   *   
   *   @ m o d u l e   q u e r y s t r i n g   
   * /   
   
 / /   I f   o b j . h a s O w n P r o p e r t y   h a s   b e e n   o v e r r i d d e n ,   t h e n   c a l l i n g   
 / /   o b j . h a s O w n P r o p e r t y ( p r o p )   w i l l   b r e a k .   
 / /   S e e :   h t t p s : / / g i t h u b . c o m / j o y e n t / n o d e / i s s u e s / 1 7 0 7   
 f u n c t i o n   h a s O w n P r o p e r t y ( o b j ,   p r o p )   {   
     r e t u r n   O b j e c t . p r o t o t y p e . h a s O w n P r o p e r t y . c a l l ( o b j ,   p r o p ) ;   
 }   
   
   
 f u n c t i o n   c h a r C o d e ( c )   {   
     r e t u r n   c . c h a r C o d e A t ( 0 ) ;   
 }   
   
   
 / /   a   s a f e   f a s t   a l t e r n a t i v e   t o   d e c o d e U R I C o m p o n e n t   
 Q u e r y S t r i n g . u n e s c a p e B u f f e r   =   f u n c t i o n ( s ,   d e c o d e S p a c e s )   {   
     v a r   o u t   =   n e w   B u f f e r ( s . l e n g t h ) ;   
     v a r   s t a t e   =   ' C H A R ' ;   / /   s t a t e s :   C H A R ,   H E X 0 ,   H E X 1   
     v a r   n ,   m ,   h e x c h a r ;   
   
     f o r   ( v a r   i n I n d e x   =   0 ,   o u t I n d e x   =   0 ;   i n I n d e x   < =   s . l e n g t h ;   i n I n d e x + + )   {   
         v a r   c   =   s . c h a r C o d e A t ( i n I n d e x ) ;   
         s w i t c h   ( s t a t e )   {   
             c a s e   ' C H A R ' :   
                     / / n o i n s p e c t i o n   F a l l T h r o u g h I n S w i t c h S t a t e m e n t J S   
                     s w i t c h   ( c )   {   
                     c a s e   c h a r C o d e ( ' % ' ) :   
                         n   =   0 ;   
                         m   =   0 ;   
                         s t a t e   =   ' H E X 0 ' ;   
                         b r e a k ;   
                     c a s e   c h a r C o d e ( ' + ' ) :   
                         i f   ( d e c o d e S p a c e s )   c   =   c h a r C o d e ( '   ' ) ;   
                         / /   p a s s   t h r u   
                     d e f a u l t :   
                         o u t [ o u t I n d e x + + ]   =   c ;   
                         b r e a k ;   
                 }   
                 b r e a k ;   
   
             c a s e   ' H E X 0 ' :   
                 s t a t e   =   ' H E X 1 ' ;   
                 h e x c h a r   =   c ;   
                 i f   ( c h a r C o d e ( ' 0 ' )   < =   c   & &   c   < =   c h a r C o d e ( ' 9 ' ) )   {   
                     n   =   c   -   c h a r C o d e ( ' 0 ' ) ;   
                 }   e l s e   i f   ( c h a r C o d e ( ' a ' )   < =   c   & &   c   < =   c h a r C o d e ( ' f ' ) )   {   
                     n   =   c   -   c h a r C o d e ( ' a ' )   +   1 0 ;   
                 }   e l s e   i f   ( c h a r C o d e ( ' A ' )   < =   c   & &   c   < =   c h a r C o d e ( ' F ' ) )   {   
                     n   =   c   -   c h a r C o d e ( ' A ' )   +   1 0 ;   
                 }   e l s e   {   
                     o u t [ o u t I n d e x + + ]   =   c h a r C o d e ( ' % ' ) ;   
                     o u t [ o u t I n d e x + + ]   =   c ;   
                     s t a t e   =   ' C H A R ' ;   
                     b r e a k ;   
                 }   
                 b r e a k ;   
   
             c a s e   ' H E X 1 ' :   
                 s t a t e   =   ' C H A R ' ;   
                 i f   ( c h a r C o d e ( ' 0 ' )   < =   c   & &   c   < =   c h a r C o d e ( ' 9 ' ) )   {   
                     m   =   c   -   c h a r C o d e ( ' 0 ' ) ;   
                 }   e l s e   i f   ( c h a r C o d e ( ' a ' )   < =   c   & &   c   < =   c h a r C o d e ( ' f ' ) )   {   
                     m   =   c   -   c h a r C o d e ( ' a ' )   +   1 0 ;   
                 }   e l s e   i f   ( c h a r C o d e ( ' A ' )   < =   c   & &   c   < =   c h a r C o d e ( ' F ' ) )   {   
                     m   =   c   -   c h a r C o d e ( ' A ' )   +   1 0 ;   
                 }   e l s e   {   
                     o u t [ o u t I n d e x + + ]   =   c h a r C o d e ( ' % ' ) ;   
                     o u t [ o u t I n d e x + + ]   =   h e x c h a r ;   
                     o u t [ o u t I n d e x + + ]   =   c ;   
                     b r e a k ;   
                 }   
                 o u t [ o u t I n d e x + + ]   =   1 6   *   n   +   m ;   
                 b r e a k ;   
         }   
     }   
   
     / /   T O D O   s u p p o r t   r e t u r n i n g   a r b i t r a r y   b u f f e r s .   
   
     r e t u r n   o u t . s l i c e ( 0 ,   o u t I n d e x   -   1 ) ;   
 } ;   
   
 / * *   
   *   T h e   u n e s c a p e   f u n c t i o n   u s e d   b y   q u e r y s t r i n g . p a r s e ,   p r o v i d e d   s o   t h a t   i t   c o u l d   b e   o v e r r i d d e n   i f   n e c e s s a r y .   
   *   
   *   @ p a r a m   s   
   *   @ p a r a m   d e c o d e S p a c e s   
   *   @ r e t u r n   { * }   
   * /   
 Q u e r y S t r i n g . u n e s c a p e   =   f u n c t i o n ( s ,   d e c o d e S p a c e s )   {   
     r e t u r n   Q u e r y S t r i n g . u n e s c a p e B u f f e r ( s ,   d e c o d e S p a c e s ) . t o S t r i n g ( ) ;   
 } ;   
   
 / * *   
   *   T h e   e s c a p e   f u n c t i o n   u s e d   b y   q u e r y s t r i n g . s t r i n g i f y ,   p r o v i d e d   s o   t h a t   i t   c o u l d   b e   o v e r r i d d e n   i f   n e c e s s a r y .   
   *   @ p a r a m   s t r   
   *   @ r e t u r n   { s t r i n g }   
   * /   
 Q u e r y S t r i n g . e s c a p e   =   f u n c t i o n ( s t r )   {   
     r e t u r n   e n c o d e U R I C o m p o n e n t ( s t r ) ;   
 } ;   
   
 v a r   s t r i n g i f y P r i m i t i v e   =   f u n c t i o n ( v )   {   
     s w i t c h   ( t y p e o f   v )   {   
         c a s e   ' s t r i n g ' :   
             r e t u r n   v ;   
   
         c a s e   ' b o o l e a n ' :   
             r e t u r n   v   ?   ' t r u e '   :   ' f a l s e ' ;   
   
         c a s e   ' n u m b e r ' :   
             r e t u r n   i s F i n i t e ( v )   ?   v   :   ' ' ;   
   
         d e f a u l t :   
             r e t u r n   ' ' ;   
     }   
 } ;   
   
 / * *   
   *   S e r i a l i z e   a n   o b j e c t   t o   a   q u e r y   s t r i n g .   O p t i o n a l l y   o v e r r i d e   t h e   d e f a u l t   s e p a r a t o r   ( ' & ' )   a n d   a s s i g n m e n t   ( ' = ' )   c h a r a c t e r s .   
   *   
   *       E x a m p l e :   
   *   
   *                 q u e r y s t r i n g . s t r i n g i f y ( {   f o o :   ' b a r ' ,   b a z :   [ ' q u x ' ,   ' q u u x ' ] ,   c o r g e :   ' '   } )   
   *                 / /   r e t u r n s   
   *                 ' f o o = b a r & b a z = q u x & b a z = q u u x & c o r g e = '   
   *   
   *                 q u e r y s t r i n g . s t r i n g i f y ( { f o o :   ' b a r ' ,   b a z :   ' q u x ' } ,   ' ; ' ,   ' : ' )   
   *                 / /   r e t u r n s   
   *                 ' f o o : b a r ; b a z : q u x '   
   *   
   *   @ p a r a m   { O b j e c t }   o b j   
   *   @ p a r a m   { S t r i n g }   [ s e p = " & " ]   
   *   @ p a r a m   { S t r i n g }   [ e q = " = " ]   
   * /   
 Q u e r y S t r i n g . s t r i n g i f y   =   Q u e r y S t r i n g . e n c o d e   =   f u n c t i o n ( o b j ,   s e p ,   e q ,   n a m e )   {   
     s e p   =   s e p   | |   ' & ' ;   
     e q   =   e q   | |   ' = ' ;   
     i f   ( o b j   = = =   n u l l )   {   
         o b j   =   u n d e f i n e d ;   
     }   
   
     i f   ( t y p e o f   o b j   = = =   ' o b j e c t ' )   {   
         r e t u r n   O b j e c t . k e y s ( o b j ) . m a p ( f u n c t i o n ( k )   {   
             v a r   k s   =   Q u e r y S t r i n g . e s c a p e ( s t r i n g i f y P r i m i t i v e ( k ) )   +   e q ;   
             i f   ( A r r a y . i s A r r a y ( o b j [ k ] ) )   {   
                 r e t u r n   o b j [ k ] . m a p ( f u n c t i o n ( v )   {   
                     r e t u r n   k s   +   Q u e r y S t r i n g . e s c a p e ( s t r i n g i f y P r i m i t i v e ( v ) ) ;   
                 } ) . j o i n ( s e p ) ;   
             }   e l s e   {   
                 r e t u r n   k s   +   Q u e r y S t r i n g . e s c a p e ( s t r i n g i f y P r i m i t i v e ( o b j [ k ] ) ) ;   
             }   
         } ) . j o i n ( s e p ) ;   
   
     }   
   
     i f   ( ! n a m e )   r e t u r n   ' ' ;   
     r e t u r n   Q u e r y S t r i n g . e s c a p e ( s t r i n g i f y P r i m i t i v e ( n a m e ) )   +   e q   +   
                   Q u e r y S t r i n g . e s c a p e ( s t r i n g i f y P r i m i t i v e ( o b j ) ) ;   
 } ;   
   
 / * *   
   *   D e s e r i a l i z e   a   q u e r y   s t r i n g   t o   a n   o b j e c t .   O p t i o n a l l y   o v e r r i d e   t h e   d e f a u l t   s e p a r a t o r   ( ' & ' )   a n d   a s s i g n m e n t   ( ' = ' )   c h a r a c t e r s .   
   *   
   *   O p t i o n s   o b j e c t   m a y   c o n t a i n   m a x K e y s   p r o p e r t y   ( e q u a l   t o   1 0 0 0   b y   d e f a u l t ) ,   i t ' l l   b e   u s e d   t o   l i m i t   p r o c e s s e d   k e y s .   S e t   i t   t o   0   t o   r e m o v e   k e y   c o u n t   l i m i t a t i o n .   
   *   
   *   E x a m p l e :   
   *   
   *                   q u e r y s t r i n g . p a r s e ( ' f o o = b a r & b a z = q u x & b a z = q u u x & c o r g e ' )   
   *                   / /   r e t u r n s   
   *                   {   f o o :   ' b a r ' ,   b a z :   [ ' q u x ' ,   ' q u u x ' ] ,   c o r g e :   ' '   }   
   *   
   *   @ m e t h o d   p a r s e   
   *   @ p a r a m   { O b j e c t }   o b j   
   *   @ p a r a m   { S t r i n g }   [ s e p = " & " ]   
   *   @ p a r a m   { S t r i n g }   [ e q = " = " ]   
   *   @ p a r a m   { O b j e c t }   [ o p t i o n s ]   
   *   @ p a r a m   { N u m b e r }   [ o p t i o n s . m a x K e y s = 1 0 0 0 ]   
   * /   
 Q u e r y S t r i n g . p a r s e   =   Q u e r y S t r i n g . d e c o d e   =   f u n c t i o n ( q s ,   s e p ,   e q ,   o p t i o n s )   {   
     s e p   =   s e p   | |   ' & ' ;   
     e q   =   e q   | |   ' = ' ;   
     v a r   o b j   =   { } ;   
   
     i f   ( t y p e o f   q s   ! = =   ' s t r i n g '   | |   q s . l e n g t h   = = =   0 )   {   
         r e t u r n   o b j ;   
     }   
   
     v a r   r e g e x p   =   / \ + / g ;   
     q s   =   q s . s p l i t ( s e p ) ;   
   
     v a r   m a x K e y s   =   1 0 0 0 ;   
     i f   ( o p t i o n s   & &   t y p e o f   o p t i o n s . m a x K e y s   = = =   ' n u m b e r ' )   {   
         m a x K e y s   =   o p t i o n s . m a x K e y s ;   
     }   
   
     v a r   l e n   =   q s . l e n g t h ;   
     / /   m a x K e y s   < =   0   m e a n s   t h a t   w e   s h o u l d   n o t   l i m i t   k e y s   c o u n t   
     i f   ( m a x K e y s   >   0   & &   l e n   >   m a x K e y s )   {   
         l e n   =   m a x K e y s ;   
     }   
   
     f o r   ( v a r   i   =   0 ;   i   <   l e n ;   + + i )   {   
         v a r   x   =   q s [ i ] . r e p l a c e ( r e g e x p ,   ' % 2 0 ' ) ,   
                 i d x   =   x . i n d e x O f ( e q ) ,   
                 k s t r ,   v s t r ,   k ,   v ;   
   
         i f   ( i d x   > =   0 )   {   
             k s t r   =   x . s u b s t r ( 0 ,   i d x ) ;   
             v s t r   =   x . s u b s t r ( i d x   +   1 ) ;   
         }   e l s e   {   
             k s t r   =   x ;   
             v s t r   =   ' ' ;   
         }   
   
         t r y   {   
             k   =   d e c o d e U R I C o m p o n e n t ( k s t r ) ;   
             v   =   d e c o d e U R I C o m p o n e n t ( v s t r ) ;   
         }   c a t c h   ( e )   {   
             k   =   Q u e r y S t r i n g . u n e s c a p e ( k s t r ,   t r u e ) ;   
             v   =   Q u e r y S t r i n g . u n e s c a p e ( v s t r ,   t r u e ) ;   
         }   
   
         i f   ( ! h a s O w n P r o p e r t y ( o b j ,   k ) )   {   
             o b j [ k ]   =   v ;   
         }   e l s e   i f   ( A r r a y . i s A r r a y ( o b j [ k ] ) )   {   
             o b j [ k ] . p u s h ( v ) ;   
         }   e l s e   {   
             o b j [ k ]   =   [ o b j [ k ] ,   v ] ;   
         }   
     }   
   
     r e t u r n   o b j ;   
 } ;   
 
 } ) ; �  L   ��
 N O D E _ M O D U L E S / S T R E A M . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ' u s e   s t r i c t ' ;   
 / * *   
   *   S e e   < a   h r e f = " h t t p s : / / n o d e j s . o r g / a p i / s t r e a m . h t m l " > N o d e   < s t r o n g > s t r e a m < / s t r o n g >   m o d u l e   d o c u m e n t a t i o n < / a >   
   *   @ m o d u l e   s t r e a m   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
 m o d u l e . e x p o r t s   =   S t r e a m ;   
   
 c o n s t   E E   =   r e q u i r e ( ' e v e n t s ' ) ;   
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
   
 u t i l . i n h e r i t s ( S t r e a m ,   E E ) ;   
 S t r e a m . R e a d a b l e   =   r e q u i r e ( ' _ s t r e a m _ r e a d a b l e ' ) ;   
 S t r e a m . W r i t a b l e   =   r e q u i r e ( ' _ s t r e a m _ w r i t a b l e ' ) ;   
 S t r e a m . D u p l e x   =   r e q u i r e ( ' _ s t r e a m _ d u p l e x ' ) ;   
 S t r e a m . T r a n s f o r m   =   r e q u i r e ( ' _ s t r e a m _ t r a n s f o r m ' ) ;   
 S t r e a m . P a s s T h r o u g h   =   r e q u i r e ( ' _ s t r e a m _ p a s s t h r o u g h ' ) ;   
   
 / /   B a c k w a r d s - c o m p a t   w i t h   n o d e   0 . 4 . x   
 S t r e a m . S t r e a m   =   S t r e a m ;   
   
   
 / /   o l d - s t y l e   s t r e a m s .     N o t e   t h a t   t h e   p i p e   m e t h o d   ( t h e   o n l y   r e l e v a n t   
 / /   p a r t   o f   t h i s   c l a s s )   i s   o v e r r i d d e n   i n   t h e   R e a d a b l e   c l a s s .   
   
 f u n c t i o n   S t r e a m ( )   {   
     E E . c a l l ( t h i s ) ;   
 }   
   
 S t r e a m . p r o t o t y p e . p i p e   =   f u n c t i o n ( d e s t ,   o p t i o n s )   {   
     v a r   s o u r c e   =   t h i s ;   
   
     f u n c t i o n   o n d a t a ( c h u n k )   {   
         i f   ( d e s t . w r i t a b l e )   {   
             i f   ( f a l s e   = = =   d e s t . w r i t e ( c h u n k )   & &   s o u r c e . p a u s e )   {   
                 s o u r c e . p a u s e ( ) ;   
             }   
         }   
     }   
   
     s o u r c e . o n ( ' d a t a ' ,   o n d a t a ) ;   
   
     f u n c t i o n   o n d r a i n ( )   {   
         i f   ( s o u r c e . r e a d a b l e   & &   s o u r c e . r e s u m e )   {   
             s o u r c e . r e s u m e ( ) ;   
         }   
     }   
   
     d e s t . o n ( ' d r a i n ' ,   o n d r a i n ) ;   
   
     / /   I f   t h e   ' e n d '   o p t i o n   i s   n o t   s u p p l i e d ,   d e s t . e n d ( )   w i l l   b e   c a l l e d   w h e n   
     / /   s o u r c e   g e t s   t h e   ' e n d '   o r   ' c l o s e '   e v e n t s .     O n l y   d e s t . e n d ( )   o n c e .   
     i f   ( ! d e s t . _ i s S t d i o   & &   ( ! o p t i o n s   | |   o p t i o n s . e n d   ! = =   f a l s e ) )   {   
         s o u r c e . o n ( ' e n d ' ,   o n e n d ) ;   
         s o u r c e . o n ( ' c l o s e ' ,   o n c l o s e ) ;   
     }   
   
     v a r   d i d O n E n d   =   f a l s e ;   
     f u n c t i o n   o n e n d ( )   {   
         i f   ( d i d O n E n d )   r e t u r n ;   
         d i d O n E n d   =   t r u e ;   
   
         d e s t . e n d ( ) ;   
     }   
   
   
     f u n c t i o n   o n c l o s e ( )   {   
         i f   ( d i d O n E n d )   r e t u r n ;   
         d i d O n E n d   =   t r u e ;   
   
         i f   ( t y p e o f   d e s t . d e s t r o y   = = =   ' f u n c t i o n ' )   d e s t . d e s t r o y ( ) ;   
     }   
   
     / /   d o n ' t   l e a v e   d a n g l i n g   p i p e s   w h e n   t h e r e   a r e   e r r o r s .   
     f u n c t i o n   o n e r r o r ( e r )   {   
         c l e a n u p ( ) ;   
         i f   ( E E . l i s t e n e r C o u n t ( t h i s ,   ' e r r o r ' )   = = =   0 )   {   
             t h r o w   e r ;   / /   U n h a n d l e d   s t r e a m   e r r o r   i n   p i p e .   
         }   
     }   
   
     s o u r c e . o n ( ' e r r o r ' ,   o n e r r o r ) ;   
     d e s t . o n ( ' e r r o r ' ,   o n e r r o r ) ;   
   
     / /   r e m o v e   a l l   t h e   e v e n t   l i s t e n e r s   t h a t   w e r e   a d d e d .   
     f u n c t i o n   c l e a n u p ( )   {   
         s o u r c e . r e m o v e L i s t e n e r ( ' d a t a ' ,   o n d a t a ) ;   
         d e s t . r e m o v e L i s t e n e r ( ' d r a i n ' ,   o n d r a i n ) ;   
   
         s o u r c e . r e m o v e L i s t e n e r ( ' e n d ' ,   o n e n d ) ;   
         s o u r c e . r e m o v e L i s t e n e r ( ' c l o s e ' ,   o n c l o s e ) ;   
   
         s o u r c e . r e m o v e L i s t e n e r ( ' e r r o r ' ,   o n e r r o r ) ;   
         d e s t . r e m o v e L i s t e n e r ( ' e r r o r ' ,   o n e r r o r ) ;   
   
         s o u r c e . r e m o v e L i s t e n e r ( ' e n d ' ,   c l e a n u p ) ;   
         s o u r c e . r e m o v e L i s t e n e r ( ' c l o s e ' ,   c l e a n u p ) ;   
   
         d e s t . r e m o v e L i s t e n e r ( ' c l o s e ' ,   c l e a n u p ) ;   
     }   
   
     s o u r c e . o n ( ' e n d ' ,   c l e a n u p ) ;   
     s o u r c e . o n ( ' c l o s e ' ,   c l e a n u p ) ;   
   
     d e s t . o n ( ' c l o s e ' ,   c l e a n u p ) ;   
   
     d e s t . e m i t ( ' p i p e ' ,   s o u r c e ) ;   
   
     / /   A l l o w   f o r   u n i x - l i k e   u s a g e :   A . p i p e ( B ) . p i p e ( C )   
     r e t u r n   d e s t ;   
 } ;   
 
 } ) ; �>  \   ��
 N O D E _ M O D U L E S / S T R I N G _ D E C O D E R . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ' u s e   s t r i c t ' ;   
 / * *     
   *   @ m o d u l e   s t r i n g _ d e c o d e r     
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 c o n s t   B u f f e r   =   r e q u i r e ( ' b u f f e r ' ) . B u f f e r ;   
 c o n s t   i n t e r n a l U t i l   =   r e q u i r e ( ' i n t e r n a l / u t i l ' ) ;   
 c o n s t   i s E n c o d i n g   =   B u f f e r [ i n t e r n a l U t i l . k I s E n c o d i n g S y m b o l ] ;   
   
 / /   D o   n o t   c a c h e   ` B u f f e r . i s E n c o d i n g `   w h e n   c h e c k i n g   e n c o d i n g   n a m e s   a s   s o m e   
 / /   m o d u l e s   m o n k e y - p a t c h   i t   t o   s u p p o r t   a d d i t i o n a l   e n c o d i n g s   
 f u n c t i o n   n o r m a l i z e E n c o d i n g ( e n c )   {   
     c o n s t   n e n c   =   i n t e r n a l U t i l . n o r m a l i z e E n c o d i n g ( e n c ) ;   
     i f   ( t y p e o f   n e n c   ! = =   ' s t r i n g '   & &   
             ( B u f f e r . i s E n c o d i n g   = = =   i s E n c o d i n g   | |   ! B u f f e r . i s E n c o d i n g ( e n c ) ) )   
         t h r o w   n e w   E r r o r ( ` U n k n o w n   e n c o d i n g :   $ { e n c } ` ) ;   
     r e t u r n   n e n c   | |   e n c ;   
 }   
   
 / /   S t r i n g D e c o d e r   p r o v i d e s   a n   i n t e r f a c e   f o r   e f f i c i e n t l y   s p l i t t i n g   a   s e r i e s   o f   
 / /   b u f f e r s   i n t o   a   s e r i e s   o f   J S   s t r i n g s   w i t h o u t   b r e a k i n g   a p a r t   m u l t i - b y t e   
 / /   c h a r a c t e r s .   
 e x p o r t s . S t r i n g D e c o d e r   =   S t r i n g D e c o d e r ;   
 f u n c t i o n   S t r i n g D e c o d e r ( e n c o d i n g )   {   
     t h i s . e n c o d i n g   =   n o r m a l i z e E n c o d i n g ( e n c o d i n g ) ;   
     v a r   n b ;   
     s w i t c h   ( t h i s . e n c o d i n g )   {   
         c a s e   ' u t f 1 6 l e ' :   
             t h i s . t e x t   =   u t f 1 6 T e x t ;   
             t h i s . e n d   =   u t f 1 6 E n d ;   
             n b   =   4 ;   
             b r e a k ;   
         c a s e   ' u t f 8 ' :   
             t h i s . f i l l L a s t   =   u t f 8 F i l l L a s t ;   
             n b   =   4 ;   
             b r e a k ;   
         c a s e   ' b a s e 6 4 ' :   
             t h i s . t e x t   =   b a s e 6 4 T e x t ;   
             t h i s . e n d   =   b a s e 6 4 E n d ;   
             n b   =   3 ;   
             b r e a k ;   
         d e f a u l t :   
             t h i s . w r i t e   =   s i m p l e W r i t e ;   
             t h i s . e n d   =   s i m p l e E n d ;   
             r e t u r n ;   
     }   
     t h i s . l a s t N e e d   =   0 ;   
     t h i s . l a s t T o t a l   =   0 ;   
     t h i s . l a s t C h a r   =   B u f f e r . a l l o c U n s a f e ( n b ) ;   
 }   
   
 S t r i n g D e c o d e r . p r o t o t y p e . w r i t e   =   f u n c t i o n ( b u f )   {   
     i f   ( b u f . l e n g t h   = = =   0 )   
         r e t u r n   ' ' ;   
     v a r   r ;   
     v a r   i ;   
     i f   ( t h i s . l a s t N e e d )   {   
         r   =   t h i s . f i l l L a s t ( b u f ) ;   
         i f   ( r   = = =   u n d e f i n e d )   
             r e t u r n   ' ' ;   
         i   =   t h i s . l a s t N e e d ;   
         t h i s . l a s t N e e d   =   0 ;   
     }   e l s e   {   
         i   =   0 ;   
     }   
     i f   ( i   <   b u f . l e n g t h )   
         r e t u r n   ( r   ?   r   +   t h i s . t e x t ( b u f ,   i )   :   t h i s . t e x t ( b u f ,   i ) ) ;   
     r e t u r n   r   | |   ' ' ;   
 } ;   
   
 S t r i n g D e c o d e r . p r o t o t y p e . e n d   =   u t f 8 E n d ;   
   
 / /   R e t u r n s   o n l y   c o m p l e t e   c h a r a c t e r s   i n   a   B u f f e r   
 S t r i n g D e c o d e r . p r o t o t y p e . t e x t   =   u t f 8 T e x t ;   
   
 / /   A t t e m p t s   t o   c o m p l e t e   a   p a r t i a l   n o n - U T F - 8   c h a r a c t e r   u s i n g   b y t e s   f r o m   a   B u f f e r   
 S t r i n g D e c o d e r . p r o t o t y p e . f i l l L a s t   =   f u n c t i o n ( b u f )   {   
     i f   ( t h i s . l a s t N e e d   < =   b u f . l e n g t h )   {   
         b u f . c o p y ( t h i s . l a s t C h a r ,   t h i s . l a s t T o t a l   -   t h i s . l a s t N e e d ,   0 ,   t h i s . l a s t N e e d ) ;   
         r e t u r n   t h i s . l a s t C h a r . t o S t r i n g ( t h i s . e n c o d i n g ,   0 ,   t h i s . l a s t T o t a l ) ;   
     }   
     b u f . c o p y ( t h i s . l a s t C h a r ,   t h i s . l a s t T o t a l   -   t h i s . l a s t N e e d ,   0 ,   b u f . l e n g t h ) ;   
     t h i s . l a s t N e e d   - =   b u f . l e n g t h ;   
 } ;   
   
 / /   C h e c k s   t h e   t y p e   o f   a   U T F - 8   b y t e ,   w h e t h e r   i t ' s   A S C I I ,   a   l e a d i n g   b y t e ,   o r   a   
 / /   c o n t i n u a t i o n   b y t e .   
 f u n c t i o n   u t f 8 C h e c k B y t e ( b y t e )   {   
     i f   ( b y t e   < =   0 x 7 F )   
         r e t u r n   0 ;   
     e l s e   i f   ( b y t e   > >   5   = = =   0 x 0 6 )   
         r e t u r n   2 ;   
     e l s e   i f   ( b y t e   > >   4   = = =   0 x 0 E )   
         r e t u r n   3 ;   
     e l s e   i f   ( b y t e   > >   3   = = =   0 x 1 E )   
         r e t u r n   4 ;   
     r e t u r n   - 1 ;   
 }   
   
 / /   C h e c k s   a t   m o s t   3   b y t e s   a t   t h e   e n d   o f   a   B u f f e r   i n   o r d e r   t o   d e t e c t   a n   
 / /   i n c o m p l e t e   m u l t i - b y t e   U T F - 8   c h a r a c t e r .   T h e   t o t a l   n u m b e r   o f   b y t e s   ( 2 ,   3 ,   o r   4 )   
 / /   n e e d e d   t o   c o m p l e t e   t h e   U T F - 8   c h a r a c t e r   ( i f   a p p l i c a b l e )   a r e   r e t u r n e d .   
 f u n c t i o n   u t f 8 C h e c k I n c o m p l e t e ( s e l f ,   b u f ,   i )   {   
     v a r   j   =   b u f . l e n g t h   -   1 ;   
     i f   ( j   <   i )   
         r e t u r n   0 ;   
     v a r   n b   =   u t f 8 C h e c k B y t e ( b u f [ j ] ) ;   
     i f   ( n b   > =   0 )   {   
         i f   ( n b   >   0 )   
             s e l f . l a s t N e e d   =   n b   -   1 ;   
         r e t u r n   n b ;   
     }   
     i f   ( - - j   <   i )   
         r e t u r n   0 ;   
     n b   =   u t f 8 C h e c k B y t e ( b u f [ j ] ) ;   
     i f   ( n b   > =   0 )   {   
         i f   ( n b   >   0 )   
             s e l f . l a s t N e e d   =   n b   -   2 ;   
         r e t u r n   n b ;   
     }   
     i f   ( - - j   <   i )   
         r e t u r n   0 ;   
     n b   =   u t f 8 C h e c k B y t e ( b u f [ j ] ) ;   
     i f   ( n b   > =   0 )   {   
         i f   ( n b   >   0 )   {   
             i f   ( n b   = = =   2 )   
                 n b   =   0 ;   
             e l s e   
                 s e l f . l a s t N e e d   =   n b   -   3 ;   
         }   
         r e t u r n   n b ;   
     }   
     r e t u r n   0 ;   
 }   
   
 / /   V a l i d a t e s   a s   m a n y   c o n t i n u a t i o n   b y t e s   f o r   a   m u l t i - b y t e   U T F - 8   c h a r a c t e r   a s   
 / /   n e e d e d   o r   a r e   a v a i l a b l e .   I f   w e   s e e   a   n o n - c o n t i n u a t i o n   b y t e   w h e r e   w e   e x p e c t   
 / /   o n e ,   w e   " r e p l a c e "   t h e   v a l i d a t e d   c o n t i n u a t i o n   b y t e s   w e ' v e   s e e n   s o   f a r   w i t h   
 / /   U T F - 8   r e p l a c e m e n t   c h a r a c t e r s   ( ' \ u f f f d ' ) ,   t o   m a t c h   v 8 ' s   U T F - 8   d e c o d i n g   
 / /   b e h a v i o r .   T h e   c o n t i n u a t i o n   b y t e   c h e c k   i s   i n c l u d e d   t h r e e   t i m e s   i n   t h e   c a s e   
 / /   w h e r e   a l l   o f   t h e   c o n t i n u a t i o n   b y t e s   f o r   a   c h a r a c t e r   e x i s t   i n   t h e   s a m e   b u f f e r .   
 / /   I t   i s   a l s o   d o n e   t h i s   w a y   a s   a   s l i g h t   p e r f o r m a n c e   i n c r e a s e   i n s t e a d   o f   u s i n g   a   
 / /   l o o p .   
 f u n c t i o n   u t f 8 C h e c k E x t r a B y t e s ( s e l f ,   b u f ,   p )   {   
     i f   ( ( b u f [ 0 ]   &   0 x C 0 )   ! = =   0 x 8 0 )   {   
         s e l f . l a s t N e e d   =   0 ;   
         r e t u r n   ' \ u f f f d ' . r e p e a t ( p ) ;   
     }   
     i f   ( s e l f . l a s t N e e d   >   1   & &   b u f . l e n g t h   >   1 )   {   
         i f   ( ( b u f [ 1 ]   &   0 x C 0 )   ! = =   0 x 8 0 )   {   
             s e l f . l a s t N e e d   =   1 ;   
             r e t u r n   ' \ u f f f d ' . r e p e a t ( p   +   1 ) ;   
         }   
         i f   ( s e l f . l a s t N e e d   >   2   & &   b u f . l e n g t h   >   2 )   {   
             i f   ( ( b u f [ 2 ]   &   0 x C 0 )   ! = =   0 x 8 0 )   {   
                 s e l f . l a s t N e e d   =   2 ;   
                 r e t u r n   ' \ u f f f d ' . r e p e a t ( p   +   2 ) ;   
             }   
         }   
     }   
 }   
   
 / /   A t t e m p t s   t o   c o m p l e t e   a   m u l t i - b y t e   U T F - 8   c h a r a c t e r   u s i n g   b y t e s   f r o m   a   B u f f e r .   
 f u n c t i o n   u t f 8 F i l l L a s t ( b u f )   {   
     c o n s t   p   =   t h i s . l a s t T o t a l   -   t h i s . l a s t N e e d ;   
     v a r   r   =   u t f 8 C h e c k E x t r a B y t e s ( t h i s ,   b u f ,   p ) ;   
     i f   ( r   ! = =   u n d e f i n e d )   
         r e t u r n   r ;   
     i f   ( t h i s . l a s t N e e d   < =   b u f . l e n g t h )   {   
         b u f . c o p y ( t h i s . l a s t C h a r ,   p ,   0 ,   t h i s . l a s t N e e d ) ;   
         r e t u r n   t h i s . l a s t C h a r . t o S t r i n g ( t h i s . e n c o d i n g ,   0 ,   t h i s . l a s t T o t a l ) ;   
     }   
     b u f . c o p y ( t h i s . l a s t C h a r ,   p ,   0 ,   b u f . l e n g t h ) ;   
     t h i s . l a s t N e e d   - =   b u f . l e n g t h ;   
 }   
   
 / /   R e t u r n s   a l l   c o m p l e t e   U T F - 8   c h a r a c t e r s   i n   a   B u f f e r .   I f   t h e   B u f f e r   e n d e d   o n   a   
 / /   p a r t i a l   c h a r a c t e r ,   t h e   c h a r a c t e r ' s   b y t e s   a r e   b u f f e r e d   u n t i l   t h e   r e q u i r e d   
 / /   n u m b e r   o f   b y t e s   a r e   a v a i l a b l e .   
 f u n c t i o n   u t f 8 T e x t ( b u f ,   i )   {   
     c o n s t   t o t a l   =   u t f 8 C h e c k I n c o m p l e t e ( t h i s ,   b u f ,   i ) ;   
     i f   ( ! t h i s . l a s t N e e d )   
         r e t u r n   b u f . t o S t r i n g ( ' u t f 8 ' ,   i ) ;   
     t h i s . l a s t T o t a l   =   t o t a l ;   
     c o n s t   e n d   =   b u f . l e n g t h   -   ( t o t a l   -   t h i s . l a s t N e e d ) ;   
     b u f . c o p y ( t h i s . l a s t C h a r ,   0 ,   e n d ) ;   
     r e t u r n   b u f . t o S t r i n g ( ' u t f 8 ' ,   i ,   e n d ) ;   
 }   
   
 / /   F o r   U T F - 8 ,   a   r e p l a c e m e n t   c h a r a c t e r   f o r   e a c h   b u f f e r e d   b y t e   o f   a   ( p a r t i a l )   
 / /   c h a r a c t e r   n e e d s   t o   b e   a d d e d   t o   t h e   o u t p u t .   
 f u n c t i o n   u t f 8 E n d ( b u f )   {   
     c o n s t   r   =   ( b u f   & &   b u f . l e n g t h   ?   t h i s . w r i t e ( b u f )   :   ' ' ) ;   
     i f   ( t h i s . l a s t N e e d )   
         r e t u r n   r   +   ' \ u f f f d ' . r e p e a t ( t h i s . l a s t T o t a l   -   t h i s . l a s t N e e d ) ;   
     r e t u r n   r ;   
 }   
   
 / /   U T F - 1 6 L E   t y p i c a l l y   n e e d s   t w o   b y t e s   p e r   c h a r a c t e r ,   b u t   e v e n   i f   w e   h a v e   a n   e v e n   
 / /   n u m b e r   o f   b y t e s   a v a i l a b l e ,   w e   n e e d   t o   c h e c k   i f   w e   e n d   o n   a   l e a d i n g / h i g h   
 / /   s u r r o g a t e .   I n   t h a t   c a s e ,   w e   n e e d   t o   w a i t   f o r   t h e   n e x t   t w o   b y t e s   i n   o r d e r   t o   
 / /   d e c o d e   t h e   l a s t   c h a r a c t e r   p r o p e r l y .   
 f u n c t i o n   u t f 1 6 T e x t ( b u f ,   i )   {   
     i f   ( ( b u f . l e n g t h   -   i )   %   2   = = =   0 )   {   
         c o n s t   r   =   b u f . t o S t r i n g ( ' u t f 1 6 l e ' ,   i ) ;   
         i f   ( r )   {   
             c o n s t   c   =   r . c h a r C o d e A t ( r . l e n g t h   -   1 ) ;   
             i f   ( c   > =   0 x D 8 0 0   & &   c   < =   0 x D B F F )   {   
                 t h i s . l a s t N e e d   =   2 ;   
                 t h i s . l a s t T o t a l   =   4 ;   
                 t h i s . l a s t C h a r [ 0 ]   =   b u f [ b u f . l e n g t h   -   2 ] ;   
                 t h i s . l a s t C h a r [ 1 ]   =   b u f [ b u f . l e n g t h   -   1 ] ;   
                 r e t u r n   r . s l i c e ( 0 ,   - 1 ) ;   
             }   
         }   
         r e t u r n   r ;   
     }   
     t h i s . l a s t N e e d   =   1 ;   
     t h i s . l a s t T o t a l   =   2 ;   
     t h i s . l a s t C h a r [ 0 ]   =   b u f [ b u f . l e n g t h   -   1 ] ;   
     r e t u r n   b u f . t o S t r i n g ( ' u t f 1 6 l e ' ,   i ,   b u f . l e n g t h   -   1 ) ;   
 }   
   
 / /   F o r   U T F - 1 6 L E   w e   d o   n o t   e x p l i c i t l y   a p p e n d   s p e c i a l   r e p l a c e m e n t   c h a r a c t e r s   i f   w e   
 / /   e n d   o n   a   p a r t i a l   c h a r a c t e r ,   w e   s i m p l y   l e t   v 8   h a n d l e   t h a t .   
 f u n c t i o n   u t f 1 6 E n d ( b u f )   {   
     c o n s t   r   =   ( b u f   & &   b u f . l e n g t h   ?   t h i s . w r i t e ( b u f )   :   ' ' ) ;   
     i f   ( t h i s . l a s t N e e d )   {   
         c o n s t   e n d   =   t h i s . l a s t T o t a l   -   t h i s . l a s t N e e d ;   
         r e t u r n   r   +   t h i s . l a s t C h a r . t o S t r i n g ( ' u t f 1 6 l e ' ,   0 ,   e n d ) ;   
     }   
     r e t u r n   r ;   
 }   
   
 f u n c t i o n   b a s e 6 4 T e x t ( b u f ,   i )   {   
     c o n s t   n   =   ( b u f . l e n g t h   -   i )   %   3 ;   
     i f   ( n   = = =   0 )   
         r e t u r n   b u f . t o S t r i n g ( ' b a s e 6 4 ' ,   i ) ;   
     t h i s . l a s t N e e d   =   3   -   n ;   
     t h i s . l a s t T o t a l   =   3 ;   
     i f   ( n   = = =   1 )   {   
         t h i s . l a s t C h a r [ 0 ]   =   b u f [ b u f . l e n g t h   -   1 ] ;   
     }   e l s e   {   
         t h i s . l a s t C h a r [ 0 ]   =   b u f [ b u f . l e n g t h   -   2 ] ;   
         t h i s . l a s t C h a r [ 1 ]   =   b u f [ b u f . l e n g t h   -   1 ] ;   
     }   
     r e t u r n   b u f . t o S t r i n g ( ' b a s e 6 4 ' ,   i ,   b u f . l e n g t h   -   n ) ;   
 }   
   
   
 f u n c t i o n   b a s e 6 4 E n d ( b u f )   {   
     c o n s t   r   =   ( b u f   & &   b u f . l e n g t h   ?   t h i s . w r i t e ( b u f )   :   ' ' ) ;   
     i f   ( t h i s . l a s t N e e d )   
         r e t u r n   r   +   t h i s . l a s t C h a r . t o S t r i n g ( ' b a s e 6 4 ' ,   0 ,   3   -   t h i s . l a s t N e e d ) ;   
     r e t u r n   r ;   
 }   
   
 / /   P a s s   b y t e s   o n   t h r o u g h   f o r   s i n g l e - b y t e   e n c o d i n g s   ( e . g .   a s c i i ,   l a t i n 1 ,   h e x )   
 f u n c t i o n   s i m p l e W r i t e ( b u f )   {   
     r e t u r n   b u f . t o S t r i n g ( t h i s . e n c o d i n g ) ;   
 }   
   
 f u n c t i o n   s i m p l e E n d ( b u f )   {   
     r e t u r n   ( b u f   & &   b u f . l e n g t h   ?   t h i s . w r i t e ( b u f )   :   ' ' ) ;   
 }   
 
 } ) ;   �  L   ��
 N O D E _ M O D U L E S / T I M E R S . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / * *   
 *     M P V   -   f a k e   i m p l e m e n t a t i o n   o f   n o d e . j s   t i m e r   
 *     J u s t   f o r   x m l 2 j s   w o r k   
 * /   
 m o d u l e . e x p o r t s   =   {   
     s e t I m m e d i a t e :   g l o b a l . s e t I m m e d i a t e   
 } 
 } ) ;   �  D   ��
 N O D E _ M O D U L E S / T T Y . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / * *   
 *   M P V   -   F a k e   i m p l e m e n t a t i o n   o f   n o d e j s   t t y   
 *   A l w a y s   r e t u r n   ` f a l s e `   t o   i s a t t y ( )   c a l l   
 *   @ m o d u l e   t t y   
 *   @ m e m b e r O f   m o d u l e : b u i l d i n   
 * /     
 e x p o r t s . i s a t t y   =   f u n c t i o n ( f d )   { 
     r e t u r n   f a l s e ; 
 } ; 
 } ) ; ,�  D   ��
 N O D E _ M O D U L E S / U R L . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ��/ * *   
   *   S e e   < a   h r e f = " h t t p s : / / n o d e j s . o r g / a p i / u r l . h t m l " > N o d e   < s t r o n g > u r l < / s t r o n g >   m o d u l e   d o c u m e n t a t i o n < / a >   
   *   @ m o d u l e   u r l   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 ' u s e   s t r i c t ' ;   
   
 c o n s t   p u n y c o d e   =   r e q u i r e ( ' p u n y c o d e ' ) ;   
   
 e x p o r t s . p a r s e   =   u r l P a r s e ;   
 e x p o r t s . r e s o l v e   =   u r l R e s o l v e ;   
 e x p o r t s . r e s o l v e O b j e c t   =   u r l R e s o l v e O b j e c t ;   
 e x p o r t s . f o r m a t   =   u r l F o r m a t ;   
   
 e x p o r t s . U r l   =   U r l ;   
   
 f u n c t i o n   U r l ( )   {   
     t h i s . p r o t o c o l   =   n u l l ;   
     t h i s . s l a s h e s   =   n u l l ;   
     t h i s . a u t h   =   n u l l ;   
     t h i s . h o s t   =   n u l l ;   
     t h i s . p o r t   =   n u l l ;   
     t h i s . h o s t n a m e   =   n u l l ;   
     t h i s . h a s h   =   n u l l ;   
     t h i s . s e a r c h   =   n u l l ;   
     t h i s . q u e r y   =   n u l l ;   
     t h i s . p a t h n a m e   =   n u l l ;   
     t h i s . p a t h   =   n u l l ;   
     t h i s . h r e f   =   n u l l ;   
 }   
   
 / /   R e f e r e n c e :   R F C   3 9 8 6 ,   R F C   1 8 0 8 ,   R F C   2 3 9 6   
   
 / /   d e f i n e   t h e s e   h e r e   s o   a t   l e a s t   t h e y   o n l y   h a v e   t o   b e   
 / /   c o m p i l e d   o n c e   o n   t h e   f i r s t   m o d u l e   l o a d .   
 c o n s t   p r o t o c o l P a t t e r n   =   / ^ ( [ a - z 0 - 9 . + - ] + : ) / i ;   
 c o n s t   p o r t P a t t e r n   =   / : [ 0 - 9 ] * $ / ;   
   
 / /   S p e c i a l   c a s e   f o r   a   s i m p l e   p a t h   U R L   
 c o n s t   s i m p l e P a t h P a t t e r n   =   / ^ ( \ / \ / ? ( ? ! \ / ) [ ^ \ ? \ s ] * ) ( \ ? [ ^ \ s ] * ) ? $ / ;   
   
 / /   R F C   2 3 9 6 :   c h a r a c t e r s   r e s e r v e d   f o r   d e l i m i t i n g   U R L s .   
 / /   W e   a c t u a l l y   j u s t   a u t o - e s c a p e   t h e s e .   
 c o n s t   d e l i m s   =   [ ' < ' ,   ' > ' ,   ' " ' ,   ' ` ' ,   '   ' ,   ' \ r ' ,   ' \ n ' ,   ' \ t ' ] ;   
   
 / /   R F C   2 3 9 6 :   c h a r a c t e r s   n o t   a l l o w e d   f o r   v a r i o u s   r e a s o n s .   
 c o n s t   u n w i s e   =   [ ' { ' ,   ' } ' ,   ' | ' ,   ' \ \ ' ,   ' ^ ' ,   ' ` ' ] . c o n c a t ( d e l i m s ) ;   
   
 / /   A l l o w e d   b y   R F C s ,   b u t   c a u s e   o f   X S S   a t t a c k s .     A l w a y s   e s c a p e   t h e s e .   
 c o n s t   a u t o E s c a p e   =   [ ' \ ' ' ] . c o n c a t ( u n w i s e ) ;   
   
 / /   C h a r a c t e r s   t h a t   a r e   n e v e r   e v e r   a l l o w e d   i n   a   h o s t n a m e .   
 / /   N o t e   t h a t   a n y   i n v a l i d   c h a r s   a r e   a l s o   h a n d l e d ,   b u t   t h e s e   
 / /   a r e   t h e   o n e s   t h a t   a r e   * e x p e c t e d *   t o   b e   s e e n ,   s o   w e   f a s t - p a t h   t h e m .   
 c o n s t   n o n H o s t C h a r s   =   [ ' % ' ,   ' / ' ,   ' ? ' ,   ' ; ' ,   ' # ' ] . c o n c a t ( a u t o E s c a p e ) ;   
 c o n s t   h o s t E n d i n g C h a r s   =   [ ' / ' ,   ' ? ' ,   ' # ' ] ;   
 c o n s t   h o s t n a m e M a x L e n   =   2 5 5 ;   
 c o n s t   h o s t n a m e P a r t P a t t e r n   =   / ^ [ + a - z 0 - 9 A - Z _ - ] { 0 , 6 3 } $ / ;   
 c o n s t   h o s t n a m e P a r t S t a r t   =   / ^ ( [ + a - z 0 - 9 A - Z _ - ] { 0 , 6 3 } ) ( . * ) $ / ;   
 / /   p r o t o c o l s   t h a t   c a n   a l l o w   " u n s a f e "   a n d   " u n w i s e "   c h a r s .   
 c o n s t   u n s a f e P r o t o c o l   =   {   
     ' j a v a s c r i p t ' :   t r u e ,   
     ' j a v a s c r i p t : ' :   t r u e   
 } ;   
 / /   p r o t o c o l s   t h a t   n e v e r   h a v e   a   h o s t n a m e .   
 c o n s t   h o s t l e s s P r o t o c o l   =   {   
     ' j a v a s c r i p t ' :   t r u e ,   
     ' j a v a s c r i p t : ' :   t r u e   
 } ;   
 / /   p r o t o c o l s   t h a t   a l w a y s   c o n t a i n   a   / /   b i t .   
 c o n s t   s l a s h e d P r o t o c o l   =   {   
     ' h t t p ' :   t r u e ,   
     ' h t t p s ' :   t r u e ,   
     ' f t p ' :   t r u e ,   
     ' g o p h e r ' :   t r u e ,   
     ' f i l e ' :   t r u e ,   
     ' h t t p : ' :   t r u e ,   
     ' h t t p s : ' :   t r u e ,   
     ' f t p : ' :   t r u e ,   
     ' g o p h e r : ' :   t r u e ,   
     ' f i l e : ' :   t r u e   
 } ;   
 c o n s t   q u e r y s t r i n g   =   r e q u i r e ( ' q u e r y s t r i n g ' ) ;   
   
 f u n c t i o n   u r l P a r s e ( u r l ,   p a r s e Q u e r y S t r i n g ,   s l a s h e s D e n o t e H o s t )   {   
     i f   ( u r l   i n s t a n c e o f   U r l )   r e t u r n   u r l ;   
   
     v a r   u   =   n e w   U r l ( ) ;   
     u . p a r s e ( u r l ,   p a r s e Q u e r y S t r i n g ,   s l a s h e s D e n o t e H o s t ) ;   
     r e t u r n   u ;   
 }   
   
 U r l . p r o t o t y p e . p a r s e   =   f u n c t i o n ( u r l ,   p a r s e Q u e r y S t r i n g ,   s l a s h e s D e n o t e H o s t )   {   
     i f   ( t y p e o f   u r l   ! = =   ' s t r i n g ' )   {   
         t h r o w   n e w   T y p e E r r o r ( ' P a r a m e t e r   " u r l "   m u s t   b e   a   s t r i n g ,   n o t   '   +   t y p e o f   u r l ) ;   
     }   
   
     / /   C o p y   c h r o m e ,   I E ,   o p e r a   b a c k s l a s h - h a n d l i n g   b e h a v i o r .   
     / /   B a c k   s l a s h e s   b e f o r e   t h e   q u e r y   s t r i n g   g e t   c o n v e r t e d   t o   f o r w a r d   s l a s h e s   
     / /   S e e :   h t t p s : / / c o d e . g o o g l e . c o m / p / c h r o m i u m / i s s u e s / d e t a i l ? i d = 2 5 9 1 6   
     v a r   q u e r y I n d e x   =   u r l . i n d e x O f ( ' ? ' ) ,   
             s p l i t t e r   =   
                     ( q u e r y I n d e x   ! = =   - 1   & &   q u e r y I n d e x   <   u r l . i n d e x O f ( ' # ' ) )   ?   ' ? '   :   ' # ' ,   
             u S p l i t   =   u r l . s p l i t ( s p l i t t e r ) ,   
             s l a s h R e g e x   =   / \ \ / g ;   
     u S p l i t [ 0 ]   =   u S p l i t [ 0 ] . r e p l a c e ( s l a s h R e g e x ,   ' / ' ) ;   
     u r l   =   u S p l i t . j o i n ( s p l i t t e r ) ;   
   
     v a r   r e s t   =   u r l ;   
   
     / /   t r i m   b e f o r e   p r o c e e d i n g .   
     / /   T h i s   i s   t o   s u p p o r t   p a r s e   s t u f f   l i k e   "     h t t p : / / f o o . c o m     \ n "   
     r e s t   =   r e s t . t r i m ( ) ;   
   
     i f   ( ! s l a s h e s D e n o t e H o s t   & &   u r l . s p l i t ( ' # ' ) . l e n g t h   = = =   1 )   {   
         / /   T r y   f a s t   p a t h   r e g e x p   
         v a r   s i m p l e P a t h   =   s i m p l e P a t h P a t t e r n . e x e c ( r e s t ) ;   
         i f   ( s i m p l e P a t h )   {   
             t h i s . p a t h   =   r e s t ;   
             t h i s . h r e f   =   r e s t ;   
             t h i s . p a t h n a m e   =   s i m p l e P a t h [ 1 ] ;   
             i f   ( s i m p l e P a t h [ 2 ] )   {   
                 t h i s . s e a r c h   =   s i m p l e P a t h [ 2 ] ;   
                 i f   ( p a r s e Q u e r y S t r i n g )   {   
                     t h i s . q u e r y   =   q u e r y s t r i n g . p a r s e ( t h i s . s e a r c h . s u b s t r ( 1 ) ) ;   
                 }   e l s e   {   
                     t h i s . q u e r y   =   t h i s . s e a r c h . s u b s t r ( 1 ) ;   
                 }   
             }   e l s e   i f   ( p a r s e Q u e r y S t r i n g )   {   
                 t h i s . s e a r c h   =   ' ' ;   
                 t h i s . q u e r y   =   { } ;   
             }   
             r e t u r n   t h i s ;   
         }   
     }   
   
     v a r   p r o t o   =   p r o t o c o l P a t t e r n . e x e c ( r e s t ) ;   
     i f   ( p r o t o )   {   
         p r o t o   =   p r o t o [ 0 ] ;   
         v a r   l o w e r P r o t o   =   p r o t o . t o L o w e r C a s e ( ) ;   
         t h i s . p r o t o c o l   =   l o w e r P r o t o ;   
         r e s t   =   r e s t . s u b s t r ( p r o t o . l e n g t h ) ;   
     }   
   
     / /   f i g u r e   o u t   i f   i t ' s   g o t   a   h o s t   
     / /   u s e r @ s e r v e r   i s   * a l w a y s *   i n t e r p r e t e d   a s   a   h o s t n a m e ,   a n d   u r l   
     / /   r e s o l u t i o n   w i l l   t r e a t   / / f o o / b a r   a s   h o s t = f o o , p a t h = b a r   b e c a u s e   t h a t ' s   
     / /   h o w   t h e   b r o w s e r   r e s o l v e s   r e l a t i v e   U R L s .   
     i f   ( s l a s h e s D e n o t e H o s t   | |   p r o t o   | |   r e s t . m a t c h ( / ^ \ / \ / [ ^ @ \ / ] + @ [ ^ @ \ / ] + / ) )   {   
         v a r   s l a s h e s   =   r e s t . s u b s t r ( 0 ,   2 )   = = =   ' / / ' ;   
         i f   ( s l a s h e s   & &   ! ( p r o t o   & &   h o s t l e s s P r o t o c o l [ p r o t o ] ) )   {   
             r e s t   =   r e s t . s u b s t r ( 2 ) ;   
             t h i s . s l a s h e s   =   t r u e ;   
         }   
     }   
   
     i f   ( ! h o s t l e s s P r o t o c o l [ p r o t o ]   & &   
             ( s l a s h e s   | |   ( p r o t o   & &   ! s l a s h e d P r o t o c o l [ p r o t o ] ) ) )   {   
   
         / /   t h e r e ' s   a   h o s t n a m e .   
         / /   t h e   f i r s t   i n s t a n c e   o f   / ,   ? ,   ; ,   o r   #   e n d s   t h e   h o s t .   
         / /   
         / /   I f   t h e r e   i s   a n   @   i n   t h e   h o s t n a m e ,   t h e n   n o n - h o s t   c h a r s   * a r e *   a l l o w e d   
         / /   t o   t h e   l e f t   o f   t h e   l a s t   @   s i g n ,   u n l e s s   s o m e   h o s t - e n d i n g   c h a r a c t e r   
         / /   c o m e s   * b e f o r e *   t h e   @ - s i g n .   
         / /   U R L s   a r e   o b n o x i o u s .   
         / /   
         / /   e x :   
         / /   h t t p : / / a @ b @ c /   = >   u s e r : a @ b   h o s t : c   
         / /   h t t p : / / a @ b ? @ c   = >   u s e r : a   h o s t : b   p a t h : / ? @ c   
   
         / /   v 0 . 1 2   T O D O ( i s a a c s ) :   T h i s   i s   n o t   q u i t e   h o w   C h r o m e   d o e s   t h i n g s .   
         / /   R e v i e w   o u r   t e s t   c a s e   a g a i n s t   b r o w s e r s   m o r e   c o m p r e h e n s i v e l y .   
   
         / /   f i n d   t h e   f i r s t   i n s t a n c e   o f   a n y   h o s t E n d i n g C h a r s   
         v a r   h o s t E n d   =   - 1 ;   
         f o r   ( v a r   i   =   0 ;   i   <   h o s t E n d i n g C h a r s . l e n g t h ;   i + + )   {   
             v a r   h e c   =   r e s t . i n d e x O f ( h o s t E n d i n g C h a r s [ i ] ) ;   
             i f   ( h e c   ! = =   - 1   & &   ( h o s t E n d   = = =   - 1   | |   h e c   <   h o s t E n d ) )   
                 h o s t E n d   =   h e c ;   
         }   
   
         / /   a t   t h i s   p o i n t ,   e i t h e r   w e   h a v e   a n   e x p l i c i t   p o i n t   w h e r e   t h e   
         / /   a u t h   p o r t i o n   c a n n o t   g o   p a s t ,   o r   t h e   l a s t   @   c h a r   i s   t h e   d e c i d e r .   
         v a r   a u t h ,   a t S i g n ;   
         i f   ( h o s t E n d   = = =   - 1 )   {   
             / /   a t S i g n   c a n   b e   a n y w h e r e .   
             a t S i g n   =   r e s t . l a s t I n d e x O f ( ' @ ' ) ;   
         }   e l s e   {   
             / /   a t S i g n   m u s t   b e   i n   a u t h   p o r t i o n .   
             / /   h t t p : / / a @ b / c @ d   = >   h o s t : b   a u t h : a   p a t h : / c @ d   
             a t S i g n   =   r e s t . l a s t I n d e x O f ( ' @ ' ,   h o s t E n d ) ;   
         }   
   
         / /   N o w   w e   h a v e   a   p o r t i o n   w h i c h   i s   d e f i n i t e l y   t h e   a u t h .   
         / /   P u l l   t h a t   o f f .   
         i f   ( a t S i g n   ! = =   - 1 )   {   
             a u t h   =   r e s t . s l i c e ( 0 ,   a t S i g n ) ;   
             r e s t   =   r e s t . s l i c e ( a t S i g n   +   1 ) ;   
             t h i s . a u t h   =   d e c o d e U R I C o m p o n e n t ( a u t h ) ;   
         }   
   
         / /   t h e   h o s t   i s   t h e   r e m a i n i n g   t o   t h e   l e f t   o f   t h e   f i r s t   n o n - h o s t   c h a r   
         h o s t E n d   =   - 1 ;   
         f o r   ( v a r   i   =   0 ;   i   <   n o n H o s t C h a r s . l e n g t h ;   i + + )   {   
             v a r   h e c   =   r e s t . i n d e x O f ( n o n H o s t C h a r s [ i ] ) ;   
             i f   ( h e c   ! = =   - 1   & &   ( h o s t E n d   = = =   - 1   | |   h e c   <   h o s t E n d ) )   
                 h o s t E n d   =   h e c ;   
         }   
         / /   i f   w e   s t i l l   h a v e   n o t   h i t   i t ,   t h e n   t h e   e n t i r e   t h i n g   i s   a   h o s t .   
         i f   ( h o s t E n d   = = =   - 1 )   
             h o s t E n d   =   r e s t . l e n g t h ;   
   
         t h i s . h o s t   =   r e s t . s l i c e ( 0 ,   h o s t E n d ) ;   
         r e s t   =   r e s t . s l i c e ( h o s t E n d ) ;   
   
         / /   p u l l   o u t   p o r t .   
         t h i s . p a r s e H o s t ( ) ;   
   
         / /   w e ' v e   i n d i c a t e d   t h a t   t h e r e   i s   a   h o s t n a m e ,   
         / /   s o   e v e n   i f   i t ' s   e m p t y ,   i t   h a s   t o   b e   p r e s e n t .   
         t h i s . h o s t n a m e   =   t h i s . h o s t n a m e   | |   ' ' ;   
   
         / /   i f   h o s t n a m e   b e g i n s   w i t h   [   a n d   e n d s   w i t h   ]   
         / /   a s s u m e   t h a t   i t ' s   a n   I P v 6   a d d r e s s .   
         v a r   i p v 6 H o s t n a m e   =   t h i s . h o s t n a m e [ 0 ]   = = =   ' [ '   & &   
                 t h i s . h o s t n a m e [ t h i s . h o s t n a m e . l e n g t h   -   1 ]   = = =   ' ] ' ;   
   
         / /   v a l i d a t e   a   l i t t l e .   
         i f   ( ! i p v 6 H o s t n a m e )   {   
             v a r   h o s t p a r t s   =   t h i s . h o s t n a m e . s p l i t ( / \ . / ) ;   
             f o r   ( v a r   i   =   0 ,   l   =   h o s t p a r t s . l e n g t h ;   i   <   l ;   i + + )   {   
                 v a r   p a r t   =   h o s t p a r t s [ i ] ;   
                 i f   ( ! p a r t )   c o n t i n u e ;   
                 i f   ( ! p a r t . m a t c h ( h o s t n a m e P a r t P a t t e r n ) )   {   
                     v a r   n e w p a r t   =   ' ' ;   
                     f o r   ( v a r   j   =   0 ,   k   =   p a r t . l e n g t h ;   j   <   k ;   j + + )   {   
                         i f   ( p a r t . c h a r C o d e A t ( j )   >   1 2 7 )   {   
                             / /   w e   r e p l a c e   n o n - A S C I I   c h a r   w i t h   a   t e m p o r a r y   p l a c e h o l d e r   
                             / /   w e   n e e d   t h i s   t o   m a k e   s u r e   s i z e   o f   h o s t n a m e   i s   n o t   
                             / /   b r o k e n   b y   r e p l a c i n g   n o n - A S C I I   b y   n o t h i n g   
                             n e w p a r t   + =   ' x ' ;   
                         }   e l s e   {   
                             n e w p a r t   + =   p a r t [ j ] ;   
                         }   
                     }   
                     / /   w e   t e s t   a g a i n   w i t h   A S C I I   c h a r   o n l y   
                     i f   ( ! n e w p a r t . m a t c h ( h o s t n a m e P a r t P a t t e r n ) )   {   
                         v a r   v a l i d P a r t s   =   h o s t p a r t s . s l i c e ( 0 ,   i ) ;   
                         v a r   n o t H o s t   =   h o s t p a r t s . s l i c e ( i   +   1 ) ;   
                         v a r   b i t   =   p a r t . m a t c h ( h o s t n a m e P a r t S t a r t ) ;   
                         i f   ( b i t )   {   
                             v a l i d P a r t s . p u s h ( b i t [ 1 ] ) ;   
                             n o t H o s t . u n s h i f t ( b i t [ 2 ] ) ;   
                         }   
                         i f   ( n o t H o s t . l e n g t h )   {   
                             r e s t   =   ' / '   +   n o t H o s t . j o i n ( ' . ' )   +   r e s t ;   
                         }   
                         t h i s . h o s t n a m e   =   v a l i d P a r t s . j o i n ( ' . ' ) ;   
                         b r e a k ;   
                     }   
                 }   
             }   
         }   
   
         i f   ( t h i s . h o s t n a m e . l e n g t h   >   h o s t n a m e M a x L e n )   {   
             t h i s . h o s t n a m e   =   ' ' ;   
         }   e l s e   {   
             / /   h o s t n a m e s   a r e   a l w a y s   l o w e r   c a s e .   
             t h i s . h o s t n a m e   =   t h i s . h o s t n a m e . t o L o w e r C a s e ( ) ;   
         }   
   
         i f   ( ! i p v 6 H o s t n a m e )   {   
             / /   I D N A   S u p p o r t :   R e t u r n s   a   p u n y c o d e d   r e p r e s e n t a t i o n   o f   " d o m a i n " .   
             / /   I t   o n l y   c o n v e r t s   p a r t s   o f   t h e   d o m a i n   n a m e   t h a t   
             / /   h a v e   n o n - A S C I I   c h a r a c t e r s ,   i . e .   i t   d o e s n ' t   m a t t e r   i f   
             / /   y o u   c a l l   i t   w i t h   a   d o m a i n   t h a t   a l r e a d y   i s   A S C I I - o n l y .   
             t h i s . h o s t n a m e   =   p u n y c o d e . t o A S C I I ( t h i s . h o s t n a m e ) ;   
         }   
   
         v a r   p   =   t h i s . p o r t   ?   ' : '   +   t h i s . p o r t   :   ' ' ;   
         v a r   h   =   t h i s . h o s t n a m e   | |   ' ' ;   
         t h i s . h o s t   =   h   +   p ;   
   
         / /   s t r i p   [   a n d   ]   f r o m   t h e   h o s t n a m e   
         / /   t h e   h o s t   f i e l d   s t i l l   r e t a i n s   t h e m ,   t h o u g h   
         i f   ( i p v 6 H o s t n a m e )   {   
             t h i s . h o s t n a m e   =   t h i s . h o s t n a m e . s u b s t r ( 1 ,   t h i s . h o s t n a m e . l e n g t h   -   2 ) ;   
             i f   ( r e s t [ 0 ]   ! = =   ' / ' )   {   
                 r e s t   =   ' / '   +   r e s t ;   
             }   
         }   
     }   
   
     / /   n o w   r e s t   i s   s e t   t o   t h e   p o s t - h o s t   s t u f f .   
     / /   c h o p   o f f   a n y   d e l i m   c h a r s .   
     i f   ( ! u n s a f e P r o t o c o l [ l o w e r P r o t o ] )   {   
   
         / /   F i r s t ,   m a k e   1 0 0 %   s u r e   t h a t   a n y   " a u t o E s c a p e "   c h a r s   g e t   
         / /   e s c a p e d ,   e v e n   i f   e n c o d e U R I C o m p o n e n t   d o e s n ' t   t h i n k   t h e y   
         / /   n e e d   t o   b e .   
         f o r   ( v a r   i   =   0 ,   l   =   a u t o E s c a p e . l e n g t h ;   i   <   l ;   i + + )   {   
             v a r   a e   =   a u t o E s c a p e [ i ] ;   
             i f   ( r e s t . i n d e x O f ( a e )   = = =   - 1 )   
                 c o n t i n u e ;   
             v a r   e s c   =   e n c o d e U R I C o m p o n e n t ( a e ) ;   
             i f   ( e s c   = = =   a e )   {   
                 e s c   =   e s c a p e ( a e ) ;   
             }   
             r e s t   =   r e s t . s p l i t ( a e ) . j o i n ( e s c ) ;   
         }   
     }   
   
   
     / /   c h o p   o f f   f r o m   t h e   t a i l   f i r s t .   
     v a r   h a s h   =   r e s t . i n d e x O f ( ' # ' ) ;   
     i f   ( h a s h   ! = =   - 1 )   {   
         / /   g o t   a   f r a g m e n t   s t r i n g .   
         t h i s . h a s h   =   r e s t . s u b s t r ( h a s h ) ;   
         r e s t   =   r e s t . s l i c e ( 0 ,   h a s h ) ;   
     }   
     v a r   q m   =   r e s t . i n d e x O f ( ' ? ' ) ;   
     i f   ( q m   ! = =   - 1 )   {   
         t h i s . s e a r c h   =   r e s t . s u b s t r ( q m ) ;   
         t h i s . q u e r y   =   r e s t . s u b s t r ( q m   +   1 ) ;   
         i f   ( p a r s e Q u e r y S t r i n g )   {   
             t h i s . q u e r y   =   q u e r y s t r i n g . p a r s e ( t h i s . q u e r y ) ;   
         }   
         r e s t   =   r e s t . s l i c e ( 0 ,   q m ) ;   
     }   e l s e   i f   ( p a r s e Q u e r y S t r i n g )   {   
         / /   n o   q u e r y   s t r i n g ,   b u t   p a r s e Q u e r y S t r i n g   s t i l l   r e q u e s t e d   
         t h i s . s e a r c h   =   ' ' ;   
         t h i s . q u e r y   =   { } ;   
     }   
     i f   ( r e s t )   t h i s . p a t h n a m e   =   r e s t ;   
     i f   ( s l a s h e d P r o t o c o l [ l o w e r P r o t o ]   & &   
             t h i s . h o s t n a m e   & &   ! t h i s . p a t h n a m e )   {   
         t h i s . p a t h n a m e   =   ' / ' ;   
     }   
   
     / / t o   s u p p o r t   h t t p . r e q u e s t   
     i f   ( t h i s . p a t h n a m e   | |   t h i s . s e a r c h )   {   
         v a r   p   =   t h i s . p a t h n a m e   | |   ' ' ;   
         v a r   s   =   t h i s . s e a r c h   | |   ' ' ;   
         t h i s . p a t h   =   p   +   s ;   
     }   
   
     / /   f i n a l l y ,   r e c o n s t r u c t   t h e   h r e f   b a s e d   o n   w h a t   h a s   b e e n   v a l i d a t e d .   
     t h i s . h r e f   =   t h i s . f o r m a t ( ) ;   
     r e t u r n   t h i s ;   
 } ;   
   
 / /   f o r m a t   a   p a r s e d   o b j e c t   i n t o   a   u r l   s t r i n g   
 f u n c t i o n   u r l F o r m a t ( o b j )   {   
     / /   e n s u r e   i t ' s   a n   o b j e c t ,   a n d   n o t   a   s t r i n g   u r l .   
     / /   I f   i t ' s   a n   o b j ,   t h i s   i s   a   n o - o p .   
     / /   t h i s   w a y ,   y o u   c a n   c a l l   u r l _ f o r m a t ( )   o n   s t r i n g s   
     / /   t o   c l e a n   u p   p o t e n t i a l l y   w o n k y   u r l s .   
     i f   ( t y p e o f   o b j   = = =   ' s t r i n g ' )   o b j   =   u r l P a r s e ( o b j ) ;   
   
     e l s e   i f   ( t y p e o f   o b j   ! = =   ' o b j e c t '   | |   o b j   = = =   n u l l )   
         t h r o w   n e w   T y p e E r r o r ( ' P a r a m e t e r   " u r l O b j "   m u s t   b e   a n   o b j e c t ,   n o t   '   +   
                                                 o b j   = = =   n u l l   ?   ' n u l l '   :   t y p e o f   o b j ) ;   
   
     e l s e   i f   ( ! ( o b j   i n s t a n c e o f   U r l ) )   r e t u r n   U r l . p r o t o t y p e . f o r m a t . c a l l ( o b j ) ;   
   
     r e t u r n   o b j . f o r m a t ( ) ;   
 }   
   
 U r l . p r o t o t y p e . f o r m a t   =   f u n c t i o n ( )   {   
     v a r   a u t h   =   t h i s . a u t h   | |   ' ' ;   
     i f   ( a u t h )   {   
         a u t h   =   e n c o d e U R I C o m p o n e n t ( a u t h ) ;   
         a u t h   =   a u t h . r e p l a c e ( / % 3 A / i ,   ' : ' ) ;   
         a u t h   + =   ' @ ' ;   
     }   
   
     v a r   p r o t o c o l   =   t h i s . p r o t o c o l   | |   ' ' ,   
             p a t h n a m e   =   t h i s . p a t h n a m e   | |   ' ' ,   
             h a s h   =   t h i s . h a s h   | |   ' ' ,   
             h o s t   =   f a l s e ,   
             q u e r y   =   ' ' ;   
   
     i f   ( t h i s . h o s t )   {   
         h o s t   =   a u t h   +   t h i s . h o s t ;   
     }   e l s e   i f   ( t h i s . h o s t n a m e )   {   
         h o s t   =   a u t h   +   ( t h i s . h o s t n a m e . i n d e x O f ( ' : ' )   = = =   - 1   ?   
                 t h i s . h o s t n a m e   :   
                 ' [ '   +   t h i s . h o s t n a m e   +   ' ] ' ) ;   
         i f   ( t h i s . p o r t )   {   
             h o s t   + =   ' : '   +   t h i s . p o r t ;   
         }   
     }   
   
     i f   ( t h i s . q u e r y   ! = =   n u l l   & &   
             t y p e o f   t h i s . q u e r y   = = =   ' o b j e c t '   & &   
             O b j e c t . k e y s ( t h i s . q u e r y ) . l e n g t h )   {   
         q u e r y   =   q u e r y s t r i n g . s t r i n g i f y ( t h i s . q u e r y ) ;   
     }   
   
     v a r   s e a r c h   =   t h i s . s e a r c h   | |   ( q u e r y   & &   ( ' ? '   +   q u e r y ) )   | |   ' ' ;   
   
     i f   ( p r o t o c o l   & &   p r o t o c o l . s u b s t r ( - 1 )   ! = =   ' : ' )   p r o t o c o l   + =   ' : ' ;   
   
     / /   o n l y   t h e   s l a s h e d P r o t o c o l s   g e t   t h e   / / .     N o t   m a i l t o : ,   x m p p : ,   e t c .   
     / /   u n l e s s   t h e y   h a d   t h e m   t o   b e g i n   w i t h .   
     i f   ( t h i s . s l a s h e s   | |   
             ( ! p r o t o c o l   | |   s l a s h e d P r o t o c o l [ p r o t o c o l ] )   & &   h o s t   ! = =   f a l s e )   {   
         h o s t   =   ' / / '   +   ( h o s t   | |   ' ' ) ;   
         i f   ( p a t h n a m e   & &   p a t h n a m e . c h a r A t ( 0 )   ! = =   ' / ' )   p a t h n a m e   =   ' / '   +   p a t h n a m e ;   
     }   e l s e   i f   ( ! h o s t )   {   
         h o s t   =   ' ' ;   
     }   
   
     i f   ( h a s h   & &   h a s h . c h a r A t ( 0 )   ! = =   ' # ' )   h a s h   =   ' # '   +   h a s h ;   
     i f   ( s e a r c h   & &   s e a r c h . c h a r A t ( 0 )   ! = =   ' ? ' )   s e a r c h   =   ' ? '   +   s e a r c h ;   
   
     p a t h n a m e   =   p a t h n a m e . r e p l a c e ( / [ ? # ] / g ,   f u n c t i o n ( m a t c h )   {   
         r e t u r n   e n c o d e U R I C o m p o n e n t ( m a t c h ) ;   
     } ) ;   
     s e a r c h   =   s e a r c h . r e p l a c e ( ' # ' ,   ' % 2 3 ' ) ;   
   
     r e t u r n   p r o t o c o l   +   h o s t   +   p a t h n a m e   +   s e a r c h   +   h a s h ;   
 } ;   
   
 f u n c t i o n   u r l R e s o l v e ( s o u r c e ,   r e l a t i v e )   {   
     r e t u r n   u r l P a r s e ( s o u r c e ,   f a l s e ,   t r u e ) . r e s o l v e ( r e l a t i v e ) ;   
 }   
   
 U r l . p r o t o t y p e . r e s o l v e   =   f u n c t i o n ( r e l a t i v e )   {   
     r e t u r n   t h i s . r e s o l v e O b j e c t ( u r l P a r s e ( r e l a t i v e ,   f a l s e ,   t r u e ) ) . f o r m a t ( ) ;   
 } ;   
   
 f u n c t i o n   u r l R e s o l v e O b j e c t ( s o u r c e ,   r e l a t i v e )   {   
     i f   ( ! s o u r c e )   r e t u r n   r e l a t i v e ;   
     r e t u r n   u r l P a r s e ( s o u r c e ,   f a l s e ,   t r u e ) . r e s o l v e O b j e c t ( r e l a t i v e ) ;   
 }   
   
 U r l . p r o t o t y p e . r e s o l v e O b j e c t   =   f u n c t i o n ( r e l a t i v e )   {   
     i f   ( t y p e o f   r e l a t i v e   = = =   ' s t r i n g ' )   {   
         v a r   r e l   =   n e w   U r l ( ) ;   
         r e l . p a r s e ( r e l a t i v e ,   f a l s e ,   t r u e ) ;   
         r e l a t i v e   =   r e l ;   
     }   
   
     v a r   r e s u l t   =   n e w   U r l ( ) ;   
     v a r   t k e y s   =   O b j e c t . k e y s ( t h i s ) ;   
     f o r   ( v a r   t k   =   0 ;   t k   <   t k e y s . l e n g t h ;   t k + + )   {   
         v a r   t k e y   =   t k e y s [ t k ] ;   
         r e s u l t [ t k e y ]   =   t h i s [ t k e y ] ;   
     }   
   
     / /   h a s h   i s   a l w a y s   o v e r r i d d e n ,   n o   m a t t e r   w h a t .   
     / /   e v e n   h r e f = " "   w i l l   r e m o v e   i t .   
     r e s u l t . h a s h   =   r e l a t i v e . h a s h ;   
   
     / /   i f   t h e   r e l a t i v e   u r l   i s   e m p t y ,   t h e n   t h e r e ' s   n o t h i n g   l e f t   t o   d o   h e r e .   
     i f   ( r e l a t i v e . h r e f   = = =   ' ' )   {   
         r e s u l t . h r e f   =   r e s u l t . f o r m a t ( ) ;   
         r e t u r n   r e s u l t ;   
     }   
   
     / /   h r e f s   l i k e   / / f o o / b a r   a l w a y s   c u t   t o   t h e   p r o t o c o l .   
     i f   ( r e l a t i v e . s l a s h e s   & &   ! r e l a t i v e . p r o t o c o l )   {   
         / /   t a k e   e v e r y t h i n g   e x c e p t   t h e   p r o t o c o l   f r o m   r e l a t i v e   
         v a r   r k e y s   =   O b j e c t . k e y s ( r e l a t i v e ) ;   
         f o r   ( v a r   r k   =   0 ;   r k   <   r k e y s . l e n g t h ;   r k + + )   {   
             v a r   r k e y   =   r k e y s [ r k ] ;   
             i f   ( r k e y   ! = =   ' p r o t o c o l ' )   
                 r e s u l t [ r k e y ]   =   r e l a t i v e [ r k e y ] ;   
         }   
   
         / / u r l P a r s e   a p p e n d s   t r a i l i n g   /   t o   u r l s   l i k e   h t t p : / / w w w . e x a m p l e . c o m   
         i f   ( s l a s h e d P r o t o c o l [ r e s u l t . p r o t o c o l ]   & &   
                 r e s u l t . h o s t n a m e   & &   ! r e s u l t . p a t h n a m e )   {   
             r e s u l t . p a t h   =   r e s u l t . p a t h n a m e   =   ' / ' ;   
         }   
   
         r e s u l t . h r e f   =   r e s u l t . f o r m a t ( ) ;   
         r e t u r n   r e s u l t ;   
     }   
   
     i f   ( r e l a t i v e . p r o t o c o l   & &   r e l a t i v e . p r o t o c o l   ! = =   r e s u l t . p r o t o c o l )   {   
         / /   i f   i t ' s   a   k n o w n   u r l   p r o t o c o l ,   t h e n   c h a n g i n g   
         / /   t h e   p r o t o c o l   d o e s   w e i r d   t h i n g s   
         / /   f i r s t ,   i f   i t ' s   n o t   f i l e : ,   t h e n   w e   M U S T   h a v e   a   h o s t ,   
         / /   a n d   i f   t h e r e   w a s   a   p a t h   
         / /   t o   b e g i n   w i t h ,   t h e n   w e   M U S T   h a v e   a   p a t h .   
         / /   i f   i t   i s   f i l e : ,   t h e n   t h e   h o s t   i s   d r o p p e d ,   
         / /   b e c a u s e   t h a t ' s   k n o w n   t o   b e   h o s t l e s s .   
         / /   a n y t h i n g   e l s e   i s   a s s u m e d   t o   b e   a b s o l u t e .   
         i f   ( ! s l a s h e d P r o t o c o l [ r e l a t i v e . p r o t o c o l ] )   {   
             v a r   k e y s   =   O b j e c t . k e y s ( r e l a t i v e ) ;   
             f o r   ( v a r   v   =   0 ;   v   <   k e y s . l e n g t h ;   v + + )   {   
                 v a r   k   =   k e y s [ v ] ;   
                 r e s u l t [ k ]   =   r e l a t i v e [ k ] ;   
             }   
             r e s u l t . h r e f   =   r e s u l t . f o r m a t ( ) ;   
             r e t u r n   r e s u l t ;   
         }   
   
         r e s u l t . p r o t o c o l   =   r e l a t i v e . p r o t o c o l ;   
         i f   ( ! r e l a t i v e . h o s t   & &   
                 ! / ^ f i l e : ? $ / . t e s t ( r e l a t i v e . p r o t o c o l )   & &   
                 ! h o s t l e s s P r o t o c o l [ r e l a t i v e . p r o t o c o l ] )   {   
             v a r   r e l P a t h   =   ( r e l a t i v e . p a t h n a m e   | |   ' ' ) . s p l i t ( ' / ' ) ;   
             w h i l e   ( r e l P a t h . l e n g t h   & &   ! ( r e l a t i v e . h o s t   =   r e l P a t h . s h i f t ( ) ) ) ;   
             i f   ( ! r e l a t i v e . h o s t )   r e l a t i v e . h o s t   =   ' ' ;   
             i f   ( ! r e l a t i v e . h o s t n a m e )   r e l a t i v e . h o s t n a m e   =   ' ' ;   
             i f   ( r e l P a t h [ 0 ]   ! = =   ' ' )   r e l P a t h . u n s h i f t ( ' ' ) ;   
             i f   ( r e l P a t h . l e n g t h   <   2 )   r e l P a t h . u n s h i f t ( ' ' ) ;   
             r e s u l t . p a t h n a m e   =   r e l P a t h . j o i n ( ' / ' ) ;   
         }   e l s e   {   
             r e s u l t . p a t h n a m e   =   r e l a t i v e . p a t h n a m e ;   
         }   
         r e s u l t . s e a r c h   =   r e l a t i v e . s e a r c h ;   
         r e s u l t . q u e r y   =   r e l a t i v e . q u e r y ;   
         r e s u l t . h o s t   =   r e l a t i v e . h o s t   | |   ' ' ;   
         r e s u l t . a u t h   =   r e l a t i v e . a u t h ;   
         r e s u l t . h o s t n a m e   =   r e l a t i v e . h o s t n a m e   | |   r e l a t i v e . h o s t ;   
         r e s u l t . p o r t   =   r e l a t i v e . p o r t ;   
         / /   t o   s u p p o r t   h t t p . r e q u e s t   
         i f   ( r e s u l t . p a t h n a m e   | |   r e s u l t . s e a r c h )   {   
             v a r   p   =   r e s u l t . p a t h n a m e   | |   ' ' ;   
             v a r   s   =   r e s u l t . s e a r c h   | |   ' ' ;   
             r e s u l t . p a t h   =   p   +   s ;   
         }   
         r e s u l t . s l a s h e s   =   r e s u l t . s l a s h e s   | |   r e l a t i v e . s l a s h e s ;   
         r e s u l t . h r e f   =   r e s u l t . f o r m a t ( ) ;   
         r e t u r n   r e s u l t ;   
     }   
   
     v a r   i s S o u r c e A b s   =   ( r e s u l t . p a t h n a m e   & &   r e s u l t . p a t h n a m e . c h a r A t ( 0 )   = = =   ' / ' ) ,   
             i s R e l A b s   =   (   
                     r e l a t i v e . h o s t   | |   
                     r e l a t i v e . p a t h n a m e   & &   r e l a t i v e . p a t h n a m e . c h a r A t ( 0 )   = = =   ' / '   
             ) ,   
             m u s t E n d A b s   =   ( i s R e l A b s   | |   i s S o u r c e A b s   | |   
                                         ( r e s u l t . h o s t   & &   r e l a t i v e . p a t h n a m e ) ) ,   
             r e m o v e A l l D o t s   =   m u s t E n d A b s ,   
             s r c P a t h   =   r e s u l t . p a t h n a m e   & &   r e s u l t . p a t h n a m e . s p l i t ( ' / ' )   | |   [ ] ,   
             r e l P a t h   =   r e l a t i v e . p a t h n a m e   & &   r e l a t i v e . p a t h n a m e . s p l i t ( ' / ' )   | |   [ ] ,   
             p s y c h o t i c   =   r e s u l t . p r o t o c o l   & &   ! s l a s h e d P r o t o c o l [ r e s u l t . p r o t o c o l ] ;   
   
     / /   i f   t h e   u r l   i s   a   n o n - s l a s h e d   u r l ,   t h e n   r e l a t i v e   
     / /   l i n k s   l i k e   . . / . .   s h o u l d   b e   a b l e   
     / /   t o   c r a w l   u p   t o   t h e   h o s t n a m e ,   a s   w e l l .     T h i s   i s   s t r a n g e .   
     / /   r e s u l t . p r o t o c o l   h a s   a l r e a d y   b e e n   s e t   b y   n o w .   
     / /   L a t e r   o n ,   p u t   t h e   f i r s t   p a t h   p a r t   i n t o   t h e   h o s t   f i e l d .   
     i f   ( p s y c h o t i c )   {   
         r e s u l t . h o s t n a m e   =   ' ' ;   
         r e s u l t . p o r t   =   n u l l ;   
         i f   ( r e s u l t . h o s t )   {   
             i f   ( s r c P a t h [ 0 ]   = = =   ' ' )   s r c P a t h [ 0 ]   =   r e s u l t . h o s t ;   
             e l s e   s r c P a t h . u n s h i f t ( r e s u l t . h o s t ) ;   
         }   
         r e s u l t . h o s t   =   ' ' ;   
         i f   ( r e l a t i v e . p r o t o c o l )   {   
             r e l a t i v e . h o s t n a m e   =   n u l l ;   
             r e l a t i v e . p o r t   =   n u l l ;   
             i f   ( r e l a t i v e . h o s t )   {   
                 i f   ( r e l P a t h [ 0 ]   = = =   ' ' )   r e l P a t h [ 0 ]   =   r e l a t i v e . h o s t ;   
                 e l s e   r e l P a t h . u n s h i f t ( r e l a t i v e . h o s t ) ;   
             }   
             r e l a t i v e . h o s t   =   n u l l ;   
         }   
         m u s t E n d A b s   =   m u s t E n d A b s   & &   ( r e l P a t h [ 0 ]   = = =   ' '   | |   s r c P a t h [ 0 ]   = = =   ' ' ) ;   
     }   
   
     i f   ( i s R e l A b s )   {   
         / /   i t ' s   a b s o l u t e .   
         r e s u l t . h o s t   =   ( r e l a t i v e . h o s t   | |   r e l a t i v e . h o s t   = = =   ' ' )   ?   
                                     r e l a t i v e . h o s t   :   r e s u l t . h o s t ;   
         r e s u l t . h o s t n a m e   =   ( r e l a t i v e . h o s t n a m e   | |   r e l a t i v e . h o s t n a m e   = = =   ' ' )   ?   
                                             r e l a t i v e . h o s t n a m e   :   r e s u l t . h o s t n a m e ;   
         r e s u l t . s e a r c h   =   r e l a t i v e . s e a r c h ;   
         r e s u l t . q u e r y   =   r e l a t i v e . q u e r y ;   
         s r c P a t h   =   r e l P a t h ;   
         / /   f a l l   t h r o u g h   t o   t h e   d o t - h a n d l i n g   b e l o w .   
     }   e l s e   i f   ( r e l P a t h . l e n g t h )   {   
         / /   i t ' s   r e l a t i v e   
         / /   t h r o w   a w a y   t h e   e x i s t i n g   f i l e ,   a n d   t a k e   t h e   n e w   p a t h   i n s t e a d .   
         i f   ( ! s r c P a t h )   s r c P a t h   =   [ ] ;   
         s r c P a t h . p o p ( ) ;   
         s r c P a t h   =   s r c P a t h . c o n c a t ( r e l P a t h ) ;   
         r e s u l t . s e a r c h   =   r e l a t i v e . s e a r c h ;   
         r e s u l t . q u e r y   =   r e l a t i v e . q u e r y ;   
     }   e l s e   i f   ( r e l a t i v e . s e a r c h   ! = =   n u l l   & &   r e l a t i v e . s e a r c h   ! = =   u n d e f i n e d )   {   
         / /   j u s t   p u l l   o u t   t h e   s e a r c h .   
         / /   l i k e   h r e f = ' ? f o o ' .   
         / /   P u t   t h i s   a f t e r   t h e   o t h e r   t w o   c a s e s   b e c a u s e   i t   s i m p l i f i e s   t h e   b o o l e a n s   
         i f   ( p s y c h o t i c )   {   
             r e s u l t . h o s t n a m e   =   r e s u l t . h o s t   =   s r c P a t h . s h i f t ( ) ;   
             / / o c c a t i o n a l y   t h e   a u t h   c a n   g e t   s t u c k   o n l y   i n   h o s t   
             / / t h i s   e s p e c i a l l y   h a p p e n s   i n   c a s e s   l i k e   
             / / u r l . r e s o l v e O b j e c t ( ' m a i l t o : l o c a l 1 @ d o m a i n 1 ' ,   ' l o c a l 2 @ d o m a i n 2 ' )   
             v a r   a u t h I n H o s t   =   r e s u l t . h o s t   & &   r e s u l t . h o s t . i n d e x O f ( ' @ ' )   >   0   ?   
                                               r e s u l t . h o s t . s p l i t ( ' @ ' )   :   f a l s e ;   
             i f   ( a u t h I n H o s t )   {   
                 r e s u l t . a u t h   =   a u t h I n H o s t . s h i f t ( ) ;   
                 r e s u l t . h o s t   =   r e s u l t . h o s t n a m e   =   a u t h I n H o s t . s h i f t ( ) ;   
             }   
         }   
         r e s u l t . s e a r c h   =   r e l a t i v e . s e a r c h ;   
         r e s u l t . q u e r y   =   r e l a t i v e . q u e r y ;   
         / / t o   s u p p o r t   h t t p . r e q u e s t   
         i f   ( r e s u l t . p a t h n a m e   ! = =   n u l l   | |   r e s u l t . s e a r c h   ! = =   n u l l )   {   
             r e s u l t . p a t h   =   ( r e s u l t . p a t h n a m e   ?   r e s u l t . p a t h n a m e   :   ' ' )   +   
                                         ( r e s u l t . s e a r c h   ?   r e s u l t . s e a r c h   :   ' ' ) ;   
         }   
         r e s u l t . h r e f   =   r e s u l t . f o r m a t ( ) ;   
         r e t u r n   r e s u l t ;   
     }   
   
     i f   ( ! s r c P a t h . l e n g t h )   {   
         / /   n o   p a t h   a t   a l l .     e a s y .   
         / /   w e ' v e   a l r e a d y   h a n d l e d   t h e   o t h e r   s t u f f   a b o v e .   
         r e s u l t . p a t h n a m e   =   n u l l ;   
         / / t o   s u p p o r t   h t t p . r e q u e s t   
         i f   ( r e s u l t . s e a r c h )   {   
             r e s u l t . p a t h   =   ' / '   +   r e s u l t . s e a r c h ;   
         }   e l s e   {   
             r e s u l t . p a t h   =   n u l l ;   
         }   
         r e s u l t . h r e f   =   r e s u l t . f o r m a t ( ) ;   
         r e t u r n   r e s u l t ;   
     }   
   
     / /   i f   a   u r l   E N D s   i n   .   o r   . . ,   t h e n   i t   m u s t   g e t   a   t r a i l i n g   s l a s h .   
     / /   h o w e v e r ,   i f   i t   e n d s   i n   a n y t h i n g   e l s e   n o n - s l a s h y ,   
     / /   t h e n   i t   m u s t   N O T   g e t   a   t r a i l i n g   s l a s h .   
     v a r   l a s t   =   s r c P a t h . s l i c e ( - 1 ) [ 0 ] ;   
     v a r   h a s T r a i l i n g S l a s h   =   (   
             ( r e s u l t . h o s t   | |   r e l a t i v e . h o s t   | |   s r c P a t h . l e n g t h   >   1 )   & &   
             ( l a s t   = = =   ' . '   | |   l a s t   = = =   ' . . ' )   | |   l a s t   = = =   ' ' ) ;   
   
     / /   s t r i p   s i n g l e   d o t s ,   r e s o l v e   d o u b l e   d o t s   t o   p a r e n t   d i r   
     / /   i f   t h e   p a t h   t r i e s   t o   g o   a b o v e   t h e   r o o t ,   ` u p `   e n d s   u p   >   0   
     v a r   u p   =   0 ;   
     f o r   ( v a r   i   =   s r c P a t h . l e n g t h ;   i   > =   0 ;   i - - )   {   
         l a s t   =   s r c P a t h [ i ] ;   
         i f   ( l a s t   = = =   ' . ' )   {   
             s p l i c e O n e ( s r c P a t h ,   i ) ;   
         }   e l s e   i f   ( l a s t   = = =   ' . . ' )   {   
             s p l i c e O n e ( s r c P a t h ,   i ) ;   
             u p + + ;   
         }   e l s e   i f   ( u p )   {   
             s p l i c e O n e ( s r c P a t h ,   i ) ;   
             u p - - ;   
         }   
     }   
   
     / /   i f   t h e   p a t h   i s   a l l o w e d   t o   g o   a b o v e   t h e   r o o t ,   r e s t o r e   l e a d i n g   . . s   
     i f   ( ! m u s t E n d A b s   & &   ! r e m o v e A l l D o t s )   {   
         f o r   ( ;   u p - - ;   u p )   {   
             s r c P a t h . u n s h i f t ( ' . . ' ) ;   
         }   
     }   
   
     i f   ( m u s t E n d A b s   & &   s r c P a t h [ 0 ]   ! = =   ' '   & &   
             ( ! s r c P a t h [ 0 ]   | |   s r c P a t h [ 0 ] . c h a r A t ( 0 )   ! = =   ' / ' ) )   {   
         s r c P a t h . u n s h i f t ( ' ' ) ;   
     }   
   
     i f   ( h a s T r a i l i n g S l a s h   & &   ( s r c P a t h . j o i n ( ' / ' ) . s u b s t r ( - 1 )   ! = =   ' / ' ) )   {   
         s r c P a t h . p u s h ( ' ' ) ;   
     }   
   
     v a r   i s A b s o l u t e   =   s r c P a t h [ 0 ]   = = =   ' '   | |   
             ( s r c P a t h [ 0 ]   & &   s r c P a t h [ 0 ] . c h a r A t ( 0 )   = = =   ' / ' ) ;   
   
     / /   p u t   t h e   h o s t   b a c k   
     i f   ( p s y c h o t i c )   {   
         r e s u l t . h o s t n a m e   =   r e s u l t . h o s t   =   i s A b s o l u t e   ?   ' '   :   
                                                                         s r c P a t h . l e n g t h   ?   s r c P a t h . s h i f t ( )   :   ' ' ;   
         / / o c c a t i o n a l y   t h e   a u t h   c a n   g e t   s t u c k   o n l y   i n   h o s t   
         / / t h i s   e s p e c i a l l y   h a p p e n s   i n   c a s e s   l i k e   
         / / u r l . r e s o l v e O b j e c t ( ' m a i l t o : l o c a l 1 @ d o m a i n 1 ' ,   ' l o c a l 2 @ d o m a i n 2 ' )   
         v a r   a u t h I n H o s t   =   r e s u l t . h o s t   & &   r e s u l t . h o s t . i n d e x O f ( ' @ ' )   >   0   ?   
                                           r e s u l t . h o s t . s p l i t ( ' @ ' )   :   f a l s e ;   
         i f   ( a u t h I n H o s t )   {   
             r e s u l t . a u t h   =   a u t h I n H o s t . s h i f t ( ) ;   
             r e s u l t . h o s t   =   r e s u l t . h o s t n a m e   =   a u t h I n H o s t . s h i f t ( ) ;   
         }   
     }   
   
     m u s t E n d A b s   =   m u s t E n d A b s   | |   ( r e s u l t . h o s t   & &   s r c P a t h . l e n g t h ) ;   
   
     i f   ( m u s t E n d A b s   & &   ! i s A b s o l u t e )   {   
         s r c P a t h . u n s h i f t ( ' ' ) ;   
     }   
   
     i f   ( ! s r c P a t h . l e n g t h )   {   
         r e s u l t . p a t h n a m e   =   n u l l ;   
         r e s u l t . p a t h   =   n u l l ;   
     }   e l s e   {   
         r e s u l t . p a t h n a m e   =   s r c P a t h . j o i n ( ' / ' ) ;   
     }   
   
     / / t o   s u p p o r t   r e q u e s t . h t t p   
     i f   ( r e s u l t . p a t h n a m e   ! = =   n u l l   | |   r e s u l t . s e a r c h   ! = =   n u l l )   {   
         r e s u l t . p a t h   =   ( r e s u l t . p a t h n a m e   ?   r e s u l t . p a t h n a m e   :   ' ' )   +   
                                     ( r e s u l t . s e a r c h   ?   r e s u l t . s e a r c h   :   ' ' ) ;   
     }   
     r e s u l t . a u t h   =   r e l a t i v e . a u t h   | |   r e s u l t . a u t h ;   
     r e s u l t . s l a s h e s   =   r e s u l t . s l a s h e s   | |   r e l a t i v e . s l a s h e s ;   
     r e s u l t . h r e f   =   r e s u l t . f o r m a t ( ) ;   
     r e t u r n   r e s u l t ;   
 } ;   
   
 U r l . p r o t o t y p e . p a r s e H o s t   =   f u n c t i o n ( )   {   
     v a r   h o s t   =   t h i s . h o s t ;   
     v a r   p o r t   =   p o r t P a t t e r n . e x e c ( h o s t ) ;   
     i f   ( p o r t )   {   
         p o r t   =   p o r t [ 0 ] ;   
         i f   ( p o r t   ! = =   ' : ' )   {   
             t h i s . p o r t   =   p o r t . s u b s t r ( 1 ) ;   
         }   
         h o s t   =   h o s t . s u b s t r ( 0 ,   h o s t . l e n g t h   -   p o r t . l e n g t h ) ;   
     }   
     i f   ( h o s t )   t h i s . h o s t n a m e   =   h o s t ;   
 } ;   
   
 / /   A b o u t   1 . 5 x   f a s t e r   t h a n   t h e   t w o - a r g   v e r s i o n   o f   A r r a y # s p l i c e ( ) .   
 f u n c t i o n   s p l i c e O n e ( l i s t ,   i n d e x )   {   
     f o r   ( v a r   i   =   i n d e x ,   k   =   i   +   1 ,   n   =   l i s t . l e n g t h ;   k   <   n ;   i   + =   1 ,   k   + =   1 )   
         l i s t [ i ]   =   l i s t [ k ] ;   
     l i s t . p o p ( ) ;   
 } 
 } ) ; � H   ��
 N O D E _ M O D U L E S / U T I L . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / * *     
   *   @ m o d u l e   u t i l     
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
 ' u s e   s t r i c t ' ;   
   
 c o n s t   u v   =   p r o c e s s . b i n d i n g ( ' u v ' ) ;   
 c o n s t   B u f f e r   =   r e q u i r e ( ' b u f f e r ' ) . B u f f e r ;   
 c o n s t   i n t e r n a l U t i l   =   r e q u i r e ( ' i n t e r n a l / u t i l ' ) ;   
 c o n s t   b i n d i n g   =   p r o c e s s . b i n d i n g ( ' u t i l ' ) ;   
   
 c o n s t   i s E r r o r   =   i n t e r n a l U t i l . i s E r r o r ;   
   
 c o n s t   i n s p e c t D e f a u l t O p t i o n s   =   O b j e c t . s e a l ( {   
     s h o w H i d d e n :   f a l s e ,   
     d e p t h :   2 ,   
     c o l o r s :   f a l s e ,   
     c u s t o m I n s p e c t :   t r u e ,   
     s h o w P r o x y :   f a l s e ,   
     m a x A r r a y L e n g t h :   1 0 0 ,   
     b r e a k L e n g t h :   6 0   
 } ) ;   
   
 v a r   D e b u g ;   
 v a r   s i m d F o r m a t t e r s ;   
   
 / /   S I M D   i s   o n l y   a v a i l a b l e   w h e n   - - h a r m o n y _ s i m d   i s   s p e c i f i e d   o n   t h e   c o m m a n d   l i n e   
 / /   a n d   t h e   s e t   o f   a v a i l a b l e   t y p e s   d i f f e r s   b e t w e e n   v 5   a n d   v 6 ,   t h a t ' s   w h y   w e   u s e   
 / /   a   m a p   t o   l o o k   u p   a n d   s t o r e   t h e   f o r m a t t e r s .     I t   a l s o   p r o v i d e s   a   m o d i c u m   o f   
 / /   p r o t e c t i o n   a g a i n s t   u s e r s   m o n k e y - p a t c h i n g   t h e   S I M D   o b j e c t .   
 i f   ( t y p e o f   g l o b a l . S I M D   = = =   ' o b j e c t '   & &   g l o b a l . S I M D   ! = =   n u l l )   {   
     s i m d F o r m a t t e r s   =   n e w   M a p ( ) ;   
   
     c o n s t   m a k e   =   ( e x t r a c t L a n e ,   c o u n t )   = >   {   
         r e t u r n   ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y s )   = >   {   
             c o n s t   o u t p u t   =   n e w   A r r a y ( c o u n t ) ;   
             f o r   ( l e t   i   =   0 ;   i   <   c o u n t ;   i   + =   1 )   
                 o u t p u t [ i ]   =   f o r m a t P r i m i t i v e ( c t x ,   e x t r a c t L a n e ( v a l u e ,   i ) ) ;   
             r e t u r n   o u t p u t ;   
         } ;   
     } ;   
   
     c o n s t   S I M D   =   g l o b a l . S I M D ;     / /   P a c i f y   e s l i n t .   
   
     i f   ( t y p e o f   S I M D . B o o l 1 6 x 8   = = =   ' f u n c t i o n ' )   
         s i m d F o r m a t t e r s . s e t ( S I M D . B o o l 1 6 x 8 ,   m a k e ( S I M D . B o o l 1 6 x 8 . e x t r a c t L a n e ,   8 ) ) ;   
   
     i f   ( t y p e o f   S I M D . B o o l 3 2 x 4   = = =   ' f u n c t i o n ' )   
         s i m d F o r m a t t e r s . s e t ( S I M D . B o o l 3 2 x 4 ,   m a k e ( S I M D . B o o l 3 2 x 4 . e x t r a c t L a n e ,   4 ) ) ;   
   
     i f   ( t y p e o f   S I M D . B o o l 8 x 1 6   = = =   ' f u n c t i o n ' )   
         s i m d F o r m a t t e r s . s e t ( S I M D . B o o l 8 x 1 6 ,   m a k e ( S I M D . B o o l 8 x 1 6 . e x t r a c t L a n e ,   1 6 ) ) ;   
   
     i f   ( t y p e o f   S I M D . F l o a t 3 2 x 4   = = =   ' f u n c t i o n ' )   
         s i m d F o r m a t t e r s . s e t ( S I M D . F l o a t 3 2 x 4 ,   m a k e ( S I M D . F l o a t 3 2 x 4 . e x t r a c t L a n e ,   4 ) ) ;   
   
     i f   ( t y p e o f   S I M D . I n t 1 6 x 8   = = =   ' f u n c t i o n ' )   
         s i m d F o r m a t t e r s . s e t ( S I M D . I n t 1 6 x 8 ,   m a k e ( S I M D . I n t 1 6 x 8 . e x t r a c t L a n e ,   8 ) ) ;   
   
     i f   ( t y p e o f   S I M D . I n t 3 2 x 4   = = =   ' f u n c t i o n ' )   
         s i m d F o r m a t t e r s . s e t ( S I M D . I n t 3 2 x 4 ,   m a k e ( S I M D . I n t 3 2 x 4 . e x t r a c t L a n e ,   4 ) ) ;   
   
     i f   ( t y p e o f   S I M D . I n t 8 x 1 6   = = =   ' f u n c t i o n ' )   
         s i m d F o r m a t t e r s . s e t ( S I M D . I n t 8 x 1 6 ,   m a k e ( S I M D . I n t 8 x 1 6 . e x t r a c t L a n e ,   1 6 ) ) ;   
   
     i f   ( t y p e o f   S I M D . U i n t 1 6 x 8   = = =   ' f u n c t i o n ' )   
         s i m d F o r m a t t e r s . s e t ( S I M D . U i n t 1 6 x 8 ,   m a k e ( S I M D . U i n t 1 6 x 8 . e x t r a c t L a n e ,   8 ) ) ;   
   
     i f   ( t y p e o f   S I M D . U i n t 3 2 x 4   = = =   ' f u n c t i o n ' )   
         s i m d F o r m a t t e r s . s e t ( S I M D . U i n t 3 2 x 4 ,   m a k e ( S I M D . U i n t 3 2 x 4 . e x t r a c t L a n e ,   4 ) ) ;   
   
     i f   ( t y p e o f   S I M D . U i n t 8 x 1 6   = = =   ' f u n c t i o n ' )   
         s i m d F o r m a t t e r s . s e t ( S I M D . U i n t 8 x 1 6 ,   m a k e ( S I M D . U i n t 8 x 1 6 . e x t r a c t L a n e ,   1 6 ) ) ;   
 }   
   
 f u n c t i o n   t r y S t r i n g i f y ( a r g )   {   
     t r y   {   
         r e t u r n   J S O N . s t r i n g i f y ( a r g ) ;   
     }   c a t c h   ( _ )   {   
         r e t u r n   ' [ C i r c u l a r ] ' ;   
     }   
 }   
   
 / * *   
   *   R e t u r n s   a   f o r m a t t e d   s t r i n g   u s i n g   t h e   f i r s t   a r g u m e n t   a s   a   p r i n t f - l i k e   f o r m a t .   
   *   
   *   T h e   f i r s t   a r g u m e n t   i s   a   s t r i n g   t h a t   c o n t a i n s   z e r o   o r   m o r e   p l a c e h o l d e r s .   E a c h   p l a c e h o l d e r   i s   r e p l a c e d   w i t h   t h e   c o n v e r t e d   v a l u e   f r o m   i t s   c o r r e s p o n d i n g   a r g u m e n t .   S u p p o r t e d   p l a c e h o l d e r s   a r e :   
   *   
   *     -   % s   -   S t r i n g .   
   *     -   % d   -   N u m b e r   ( b o t h   i n t e g e r   a n d   f l o a t ) .   
   *     -   % j   -   J S O N .   
   *     -   %   -   s i n g l e   p e r c e n t   s i g n   ( ' % ' ) .   T h i s   d o e s   n o t   c o n s u m e   a n   a r g u m e n t .   
   *   
   *   I f   t h e   p l a c e h o l d e r   d o e s   n o t   h a v e   a   c o r r e s p o n d i n g   a r g u m e n t ,   t h e   p l a c e h o l d e r   i s   n o t   r e p l a c e d :   
   *   
   *             u t i l . f o r m a t ( ' % s : % s ' ,   ' f o o ' ) ;   / /   ' f o o : % s '   
   *   
   *   I f   t h e r e   a r e   m o r e   a r g u m e n t s   t h a n   p l a c e h o l d e r s ,   t h e   e x t r a   a r g u m e n t s   a r e   c o n v e r t e d   t o   s t r i n g s   w i t h   u t i l . i n s p e c t ( )   a n d   t h e s e   s t r i n g s   a r e   c o n c a t e n a t e d ,   d e l i m i t e d   b y   a   s p a c e :   
   *   
   *             u t i l . f o r m a t ( ' % s : % s ' ,   ' f o o ' ,   ' b a r ' ,   ' b a z ' ) ;   / /   ' f o o : b a r   b a z '   
   *   
   *   I f   t h e   f i r s t   a r g u m e n t   i s   n o t   a   f o r m a t   s t r i n g   t h e n   u t i l . f o r m a t ( )   r e t u r n s   a   s t r i n g   t h a t   i s   t h e   c o n c a t e n a t i o n   o f   a l l   i t s   a r g u m e n t s   s e p a r a t e d   b y   s p a c e s .   E a c h   a r g u m e n t   i s   c o n v e r t e d   t o   a   s t r i n g   w i t h   u t i l . i n s p e c t ( ) :   
   *   
   *             u t i l . f o r m a t ( 1 ,   2 ,   3 ) ;   / /   ' 1   2   3 '   
   *   
   *   @ p a r a m   f   
   *   @ r e t u r n   { s t r i n g }   
   * /   
 e x p o r t s . f o r m a t   =   f u n c t i o n ( f )   {   
     i f   ( t y p e o f   f   ! = =   ' s t r i n g ' )   {   
         c o n s t   o b j e c t s   =   n e w   A r r a y ( a r g u m e n t s . l e n g t h ) ;   
         f o r   ( v a r   i n d e x   =   0 ;   i n d e x   <   a r g u m e n t s . l e n g t h ;   i n d e x + + )   {   
             o b j e c t s [ i n d e x ]   =   i n s p e c t ( a r g u m e n t s [ i n d e x ] ) ;   
         }   
         r e t u r n   o b j e c t s . j o i n ( '   ' ) ;   
     }   
   
     v a r   a r g L e n   =   a r g u m e n t s . l e n g t h ;   
   
     i f   ( a r g L e n   = = =   1 )   r e t u r n   f ;   
   
     v a r   s t r   =   ' ' ;   
     v a r   a   =   1 ;   
     v a r   l a s t P o s   =   0 ;   
     f o r   ( v a r   i   =   0 ;   i   <   f . l e n g t h ; )   {   
         i f   ( f . c h a r C o d e A t ( i )   = = =   3 7 / * ' % ' * /   & &   i   +   1   <   f . l e n g t h )   {   
             s w i t c h   ( f . c h a r C o d e A t ( i   +   1 ) )   {   
                 c a s e   1 0 0 :   / /   ' d '   
                     i f   ( a   > =   a r g L e n )   
                         b r e a k ;   
                     i f   ( l a s t P o s   <   i )   
                         s t r   + =   f . s l i c e ( l a s t P o s ,   i ) ;   
                     s t r   + =   N u m b e r ( a r g u m e n t s [ a + + ] ) ;   
                     l a s t P o s   =   i   =   i   +   2 ;   
                     c o n t i n u e ;   
                 c a s e   1 0 6 :   / /   ' j '   
                     i f   ( a   > =   a r g L e n )   
                         b r e a k ;   
                     i f   ( l a s t P o s   <   i )   
                         s t r   + =   f . s l i c e ( l a s t P o s ,   i ) ;   
                     s t r   + =   t r y S t r i n g i f y ( a r g u m e n t s [ a + + ] ) ;   
                     l a s t P o s   =   i   =   i   +   2 ;   
                     c o n t i n u e ;   
                 c a s e   1 1 5 :   / /   ' s '   
                     i f   ( a   > =   a r g L e n )   
                         b r e a k ;   
                     i f   ( l a s t P o s   <   i )   
                         s t r   + =   f . s l i c e ( l a s t P o s ,   i ) ;   
                     s t r   + =   S t r i n g ( a r g u m e n t s [ a + + ] ) ;   
                     l a s t P o s   =   i   =   i   +   2 ;   
                     c o n t i n u e ;   
                 c a s e   3 7 :   / /   ' % '   
                     i f   ( l a s t P o s   <   i )   
                         s t r   + =   f . s l i c e ( l a s t P o s ,   i ) ;   
                     s t r   + =   ' % ' ;   
                     l a s t P o s   =   i   =   i   +   2 ;   
                     c o n t i n u e ;   
             }   
         }   
         + + i ;   
     }   
     i f   ( l a s t P o s   = = =   0 )   
         s t r   =   f ;   
     e l s e   i f   ( l a s t P o s   <   f . l e n g t h )   
         s t r   + =   f . s l i c e ( l a s t P o s ) ;   
     w h i l e   ( a   <   a r g L e n )   {   
         c o n s t   x   =   a r g u m e n t s [ a + + ] ;   
         i f   ( x   = = =   n u l l   | |   ( t y p e o f   x   ! = =   ' o b j e c t '   & &   t y p e o f   x   ! = =   ' s y m b o l ' ) )   {   
             s t r   + =   '   '   +   x ;   
         }   e l s e   {   
             s t r   + =   '   '   +   i n s p e c t ( x ) ;   
         }   
     }   
     r e t u r n   s t r ;   
 } ;   
   
   
 / /   M a r k   t h a t   a   m e t h o d   s h o u l d   n o t   b e   u s e d .   
 / /   R e t u r n s   a   m o d i f i e d   f u n c t i o n   w h i c h   w a r n s   o n c e   b y   d e f a u l t .   
 / /   I f   - - n o - d e p r e c a t i o n   i s   s e t ,   t h e n   i t   i s   a   n o - o p .   
 e x p o r t s . d e p r e c a t e   =   i n t e r n a l U t i l . _ d e p r e c a t e ;   
   
   
 v a r   d e b u g s   =   { } ;   
 v a r   d e b u g E n v i r o n ;   
 e x p o r t s . d e b u g l o g   =   f u n c t i o n ( s e t )   {   
     i f   ( d e b u g E n v i r o n   = = =   u n d e f i n e d )   
         d e b u g E n v i r o n   =   p r o c e s s . e n v . N O D E _ D E B U G   | |   ' ' ;   
     s e t   =   s e t . t o U p p e r C a s e ( ) ;   
     i f   ( ! d e b u g s [ s e t ] )   {   
         i f   ( n e w   R e g E x p ( ' \ \ b '   +   s e t   +   ' \ \ b ' ,   ' i ' ) . t e s t ( d e b u g E n v i r o n ) )   {   
             v a r   p i d   =   p r o c e s s . p i d ;   
             d e b u g s [ s e t ]   =   f u n c t i o n ( )   {   
                 v a r   m s g   =   e x p o r t s . f o r m a t . a p p l y ( e x p o r t s ,   a r g u m e n t s ) ;   
                 c o n s o l e . e r r o r ( ' % s   % d :   % s ' ,   s e t ,   p i d ,   m s g ) ;   
             } ;   
         }   e l s e   {   
             d e b u g s [ s e t ]   =   f u n c t i o n ( )   { } ;   
         }   
     }   
     r e t u r n   d e b u g s [ s e t ] ;   
 } ;   
   
   
 / * *   
   *   E c h o s   t h e   v a l u e   o f   a   v a l u e .   T r i e s   t o   p r i n t   t h e   v a l u e   o u t   
   *   i n   t h e   b e s t   w a y   p o s s i b l e   g i v e n   t h e   d i f f e r e n t   t y p e s .   
   *   
   *   @ p a r a m   { O b j e c t }   o b j   T h e   o b j e c t   t o   p r i n t   o u t .   
   *   @ p a r a m   { O b j e c t }   o p t s   O p t i o n a l   o p t i o n s   o b j e c t   t h a t   a l t e r s   t h e   o u t p u t .   
   * /   
 / *   l e g a c y :   o b j ,   s h o w H i d d e n ,   d e p t h ,   c o l o r s * /   
 f u n c t i o n   i n s p e c t ( o b j ,   o p t s )   {   
     / /   d e f a u l t   o p t i o n s   
     v a r   c t x   =   {   
         s e e n :   [ ] ,   
         s t y l i z e :   s t y l i z e N o C o l o r   
     } ;   
     / /   l e g a c y . . .   
     i f   ( a r g u m e n t s [ 2 ]   ! = =   u n d e f i n e d )   c t x . d e p t h   =   a r g u m e n t s [ 2 ] ;   
     i f   ( a r g u m e n t s [ 3 ]   ! = =   u n d e f i n e d )   c t x . c o l o r s   =   a r g u m e n t s [ 3 ] ;   
     i f   ( t y p e o f   o p t s   = = =   ' b o o l e a n ' )   {   
         / /   l e g a c y . . .   
         c t x . s h o w H i d d e n   =   o p t s ;   
     }   
     / /   S e t   d e f a u l t   a n d   u s e r - s p e c i f i e d   o p t i o n s   
     c t x   =   O b j e c t . a s s i g n ( { } ,   i n s p e c t . d e f a u l t O p t i o n s ,   c t x ,   o p t s ) ;   
     i f   ( c t x . c o l o r s )   c t x . s t y l i z e   =   s t y l i z e W i t h C o l o r ;   
     i f   ( c t x . m a x A r r a y L e n g t h   = = =   n u l l )   c t x . m a x A r r a y L e n g t h   =   I n f i n i t y ;   
     r e t u r n   f o r m a t V a l u e ( c t x ,   o b j ,   c t x . d e p t h ) ;   
 }   
   
 O b j e c t . d e f i n e P r o p e r t y ( i n s p e c t ,   ' d e f a u l t O p t i o n s ' ,   {   
     g e t :   f u n c t i o n ( )   {   
         r e t u r n   i n s p e c t D e f a u l t O p t i o n s ;   
     } ,   
     s e t :   f u n c t i o n ( o p t i o n s )   {   
         i f   ( o p t i o n s   = = =   n u l l   | |   t y p e o f   o p t i o n s   ! = =   ' o b j e c t ' )   {   
             t h r o w   n e w   T y p e E r r o r ( ' " o p t i o n s "   m u s t   b e   a n   o b j e c t ' ) ;   
         }   
         O b j e c t . a s s i g n ( i n s p e c t D e f a u l t O p t i o n s ,   o p t i o n s ) ;   
         r e t u r n   i n s p e c t D e f a u l t O p t i o n s ;   
     }   
 } ) ;   
   
 / /   h t t p : / / e n . w i k i p e d i a . o r g / w i k i / A N S I _ e s c a p e _ c o d e # g r a p h i c s   
 i n s p e c t . c o l o r s   =   {   
     ' b o l d ' :   [ 1 ,   2 2 ] ,   
     ' i t a l i c ' :   [ 3 ,   2 3 ] ,   
     ' u n d e r l i n e ' :   [ 4 ,   2 4 ] ,   
     ' i n v e r s e ' :   [ 7 ,   2 7 ] ,   
     ' w h i t e ' :   [ 3 7 ,   3 9 ] ,   
     ' g r e y ' :   [ 9 0 ,   3 9 ] ,   
     ' b l a c k ' :   [ 3 0 ,   3 9 ] ,   
     ' b l u e ' :   [ 3 4 ,   3 9 ] ,   
     ' c y a n ' :   [ 3 6 ,   3 9 ] ,   
     ' g r e e n ' :   [ 3 2 ,   3 9 ] ,   
     ' m a g e n t a ' :   [ 3 5 ,   3 9 ] ,   
     ' r e d ' :   [ 3 1 ,   3 9 ] ,   
     ' y e l l o w ' :   [ 3 3 ,   3 9 ]   
 } ;   
   
 / /   D o n ' t   u s e   ' b l u e '   n o t   v i s i b l e   o n   c m d . e x e   
 i n s p e c t . s t y l e s   =   {   
     ' s p e c i a l ' :   ' c y a n ' ,   
     ' n u m b e r ' :   ' y e l l o w ' ,   
     ' b o o l e a n ' :   ' y e l l o w ' ,   
     ' u n d e f i n e d ' :   ' g r e y ' ,   
     ' n u l l ' :   ' b o l d ' ,   
     ' s t r i n g ' :   ' g r e e n ' ,   
     ' s y m b o l ' :   ' g r e e n ' ,   
     ' d a t e ' :   ' m a g e n t a ' ,   
     / /   " n a m e " :   i n t e n t i o n a l l y   n o t   s t y l i n g   
     ' r e g e x p ' :   ' r e d '   
 } ;   
   
 c o n s t   c u s t o m I n s p e c t S y m b o l   =   i n t e r n a l U t i l . c u s t o m I n s p e c t S y m b o l ;   
   
 e x p o r t s . i n s p e c t   =   i n s p e c t ;   
 e x p o r t s . i n s p e c t . c u s t o m   =   c u s t o m I n s p e c t S y m b o l ;   
   
 f u n c t i o n   s t y l i z e W i t h C o l o r ( s t r ,   s t y l e T y p e )   {   
     v a r   s t y l e   =   i n s p e c t . s t y l e s [ s t y l e T y p e ] ;   
   
     i f   ( s t y l e )   {   
         r e t u r n   ' \ u 0 0 1 b [ '   +   i n s p e c t . c o l o r s [ s t y l e ] [ 0 ]   +   ' m '   +   s t r   +   
                       ' \ u 0 0 1 b [ '   +   i n s p e c t . c o l o r s [ s t y l e ] [ 1 ]   +   ' m ' ;   
     }   e l s e   {   
         r e t u r n   s t r ;   
     }   
 }   
   
   
 f u n c t i o n   s t y l i z e N o C o l o r ( s t r ,   s t y l e T y p e )   {   
     r e t u r n   s t r ;   
 }   
   
   
 f u n c t i o n   a r r a y T o H a s h ( a r r a y )   {   
     v a r   h a s h   =   O b j e c t . c r e a t e ( n u l l ) ;   
   
     f o r   ( v a r   i   =   0 ;   i   <   a r r a y . l e n g t h ;   i + + )   {   
         v a r   v a l   =   a r r a y [ i ] ;   
         h a s h [ v a l ]   =   t r u e ;   
     }   
   
     r e t u r n   h a s h ;   
 }   
   
   
 f u n c t i o n   g e t C o n s t r u c t o r O f ( o b j )   {   
     w h i l e   ( o b j )   {   
         v a r   d e s c r i p t o r   =   O b j e c t . g e t O w n P r o p e r t y D e s c r i p t o r ( o b j ,   ' c o n s t r u c t o r ' ) ;   
         i f   ( d e s c r i p t o r   ! = =   u n d e f i n e d   & &   
                 t y p e o f   d e s c r i p t o r . v a l u e   = = =   ' f u n c t i o n '   & &   
                 d e s c r i p t o r . v a l u e . n a m e   ! = =   ' ' )   {   
             r e t u r n   d e s c r i p t o r . v a l u e ;   
         }   
   
         o b j   =   O b j e c t . g e t P r o t o t y p e O f ( o b j ) ;   
     }   
   
     r e t u r n   n u l l ;   
 }   
   
   
 f u n c t i o n   e n s u r e D e b u g I s I n i t i a l i z e d ( )   {   
     i f   ( D e b u g   = = =   u n d e f i n e d )   {   
         c o n s t   r u n I n D e b u g C o n t e x t   =   r e q u i r e ( ' v m ' ) . r u n I n D e b u g C o n t e x t ;   
         D e b u g   =   r u n I n D e b u g C o n t e x t ( ' D e b u g ' ) ;   
     }   
 }   
   
   
 f u n c t i o n   i n s p e c t P r o m i s e ( p )   {   
     e n s u r e D e b u g I s I n i t i a l i z e d ( ) ;   
     / /   O n l y   c r e a t e   a   m i r r o r   i f   t h e   o b j e c t   i s   a   P r o m i s e .   
     i f   ( ! b i n d i n g . i s P r o m i s e ( p ) )   
         r e t u r n   n u l l ;   
     c o n s t   m i r r o r   =   D e b u g . M a k e M i r r o r ( p ,   t r u e ) ;   
     r e t u r n   { s t a t u s :   m i r r o r . s t a t u s ( ) ,   v a l u e :   m i r r o r . p r o m i s e V a l u e ( ) . v a l u e _ } ;   
 }   
   
   
 f u n c t i o n   f o r m a t V a l u e ( c t x ,   v a l u e ,   r e c u r s e T i m e s )   {   
     i f   ( c t x . s h o w P r o x y   & &   
             ( ( t y p e o f   v a l u e   = = =   ' o b j e c t '   & &   v a l u e   ! = =   n u l l )   | |   
               t y p e o f   v a l u e   = = =   ' f u n c t i o n ' ) )   {   
         v a r   p r o x y   =   u n d e f i n e d ;   
         v a r   p r o x y C a c h e   =   c t x . p r o x y C a c h e ;   
         i f   ( ! p r o x y C a c h e )   
             p r o x y C a c h e   =   c t x . p r o x y C a c h e   =   n e w   M a p ( ) ;   
         / /   D e t e r m i n e   i f   w e ' v e   a l r e a d y   s e e n   t h i s   o b j e c t   a n d   h a v e   
         / /   d e t e r m i n e d   t h a t   i t   e i t h e r   i s   o r   i s   n o t   a   p r o x y .   
         i f   ( p r o x y C a c h e . h a s ( v a l u e ) )   {   
             / /   W e ' v e   s e e n   i t ,   i f   t h e   v a l u e   i s   n o t   u n d e f i n e d ,   i t ' s   a   P r o x y .   
             p r o x y   =   p r o x y C a c h e . g e t ( v a l u e ) ;   
         }   e l s e   {   
             / /   H a v e n ' t   s e e n   i t .   N e e d   t o   c h e c k .   
             / /   I f   i t ' s   n o t   a   P r o x y ,   t h i s   w i l l   r e t u r n   u n d e f i n e d .   
             / /   O t h e r w i s e ,   i t ' l l   r e t u r n   a n   a r r a y .   T h e   f i r s t   i t e m   
             / /   i s   t h e   t a r g e t ,   t h e   s e c o n d   i t e m   i s   t h e   h a n d l e r .   
             / /   W e   i g n o r e   ( a n d   d o   n o t   r e t u r n )   t h e   P r o x y   i s R e v o k e d   p r o p e r t y .   
             p r o x y   =   b i n d i n g . g e t P r o x y D e t a i l s ( v a l u e ) ;   
             i f   ( p r o x y )   {   
                 / /   W e   k n o w   f o r   a   f a c t   t h a t   t h i s   i s n ' t   a   P r o x y .   
                 / /   M a r k   i t   a s   h a v i n g   a l r e a d y   b e e n   e v a l u a t e d .   
                 / /   W e   d o   t h i s   b e c a u s e   t h i s   o b j e c t   i s   p a s s e d   
                 / /   r e c u r s i v e l y   t o   f o r m a t V a l u e   b e l o w   i n   o r d e r   
                 / /   f o r   i t   t o   g e t   p r o p e r   f o r m a t t i n g ,   a n d   b e c a u s e   
                 / /   t h e   t a r g e t   a n d   h a n d l e   o b j e c t s   a l s o   m i g h t   b e   
                 / /   p r o x i e s . . .   i t ' s   u n f o r t u n a t e   b u t   n e c e s s a r y .   
                 p r o x y C a c h e . s e t ( p r o x y ,   u n d e f i n e d ) ;   
             }   
             / /   I f   t h e   o b j e c t   i s   n o t   a   P r o x y ,   t h e n   t h i s   s t o r e s   u n d e f i n e d .   
             / /   T h i s   t e l l s   t h e   c o d e   a b o v e   t h a t   w e ' v e   a l r e a d y   c h e c k e d   a n d   
             / /   r u l e d   i t   o u t .   I f   t h e   o b j e c t   i s   a   p r o x y ,   t h i s   c a c h e s   t h e   
             / /   r e s u l t s   o f   t h e   g e t P r o x y D e t a i l s   c a l l .   
             p r o x y C a c h e . s e t ( v a l u e ,   p r o x y ) ;   
         }   
         i f   ( p r o x y )   {   
             r e t u r n   ' P r o x y   '   +   f o r m a t V a l u e ( c t x ,   p r o x y ,   r e c u r s e T i m e s ) ;   
         }   
     }   
   
     / /   P r o v i d e   a   h o o k   f o r   u s e r - s p e c i f i e d   i n s p e c t   f u n c t i o n s .   
     / /   C h e c k   t h a t   v a l u e   i s   a n   o b j e c t   w i t h   a n   i n s p e c t   f u n c t i o n   o n   i t   
     i f   ( c t x . c u s t o m I n s p e c t   & &   v a l u e )   {   
         c o n s t   m a y b e C u s t o m I n s p e c t   =   v a l u e [ c u s t o m I n s p e c t S y m b o l ]   | |   v a l u e . i n s p e c t ;   
   
         i f   ( t y p e o f   m a y b e C u s t o m I n s p e c t   = = =   ' f u n c t i o n '   & &   
                 / /   F i l t e r   o u t   t h e   u t i l   m o d u l e ,   i t s   i n s p e c t   f u n c t i o n   i s   s p e c i a l   
                 m a y b e C u s t o m I n s p e c t   ! = =   e x p o r t s . i n s p e c t   & &   
                 / /   A l s o   f i l t e r   o u t   a n y   p r o t o t y p e   o b j e c t s   u s i n g   t h e   c i r c u l a r   c h e c k .   
                 ! ( v a l u e . c o n s t r u c t o r   & &   v a l u e . c o n s t r u c t o r . p r o t o t y p e   = = =   v a l u e ) )   {   
             l e t   r e t   =   m a y b e C u s t o m I n s p e c t . c a l l ( v a l u e ,   r e c u r s e T i m e s ,   c t x ) ;   
   
             / /   I f   t h e   c u s t o m   i n s p e c t i o n   m e t h o d   r e t u r n e d   ` t h i s ` ,   d o n ' t   g o   i n t o   
             / /   i n f i n i t e   r e c u r s i o n .   
             i f   ( r e t   ! = =   v a l u e )   {   
                 i f   ( t y p e o f   r e t   ! = =   ' s t r i n g ' )   {   
                     r e t   =   f o r m a t V a l u e ( c t x ,   r e t ,   r e c u r s e T i m e s ) ;   
                 }   
                 r e t u r n   r e t ;   
             }   
         }   
     }   
   
     / /   P r i m i t i v e   t y p e s   c a n n o t   h a v e   p r o p e r t i e s   
     v a r   p r i m i t i v e   =   f o r m a t P r i m i t i v e ( c t x ,   v a l u e ) ;   
     i f   ( p r i m i t i v e )   {   
         r e t u r n   p r i m i t i v e ;   
     }   
   
     / /   L o o k   u p   t h e   k e y s   o f   t h e   o b j e c t .   
     v a r   k e y s   =   O b j e c t . k e y s ( v a l u e ) ;   
     v a r   v i s i b l e K e y s   =   a r r a y T o H a s h ( k e y s ) ;   
   
     i f   ( c t x . s h o w H i d d e n )   {   
         k e y s   =   O b j e c t . g e t O w n P r o p e r t y N a m e s ( v a l u e ) ;   
         k e y s   =   k e y s . c o n c a t ( O b j e c t . g e t O w n P r o p e r t y S y m b o l s ( v a l u e ) ) ;   
     }   
   
     / /   T h i s   c o u l d   b e   a   b o x e d   p r i m i t i v e   ( n e w   S t r i n g ( ) ,   e t c . ) ,   c h e c k   v a l u e O f ( )   
     / /   N O T E :   A v o i d   c a l l i n g   ` v a l u e O f `   o n   ` D a t e `   i n s t a n c e   b e c a u s e   i t   w i l l   r e t u r n   
     / /   a   n u m b e r   w h i c h ,   w h e n   o b j e c t   h a s   s o m e   a d d i t i o n a l   u s e r - s t o r e d   ` k e y s ` ,   
     / /   w i l l   b e   p r i n t e d   o u t .   
     v a r   f o r m a t t e d ;   
     v a r   r a w   =   v a l u e ;   
     t r y   {   
         / /   t h e   . v a l u e O f ( )   c a l l   c a n   f a i l   f o r   a   m u l t i t u d e   o f   r e a s o n s   
         i f   ( ! i s D a t e ( v a l u e ) )   
             r a w   =   v a l u e . v a l u e O f ( ) ;   
     }   c a t c h   ( e )   {   
         / /   i g n o r e . . .   
     }   
   
     i f   ( t y p e o f   r a w   = = =   ' s t r i n g ' )   {   
         / /   f o r   b o x e d   S t r i n g s ,   w e   h a v e   t o   r e m o v e   t h e   0 - n   i n d e x e d   e n t r i e s ,   
         / /   s i n c e   t h e y   j u s t   n o i s y   u p   t h e   o u t p u t   a n d   a r e   r e d u n d a n t   
         k e y s   =   k e y s . f i l t e r ( f u n c t i o n ( k e y )   {   
             r e t u r n   ! ( k e y   > =   0   & &   k e y   <   r a w . l e n g t h ) ;   
         } ) ;   
     }   
   
     / /   S o m e   t y p e   o f   o b j e c t   w i t h o u t   p r o p e r t i e s   c a n   b e   s h o r t c u t t e d .   
     i f   ( k e y s . l e n g t h   = = =   0 )   {   
         i f   ( t y p e o f   v a l u e   = = =   ' f u n c t i o n ' )   {   
             v a r   n a m e   =   v a l u e . n a m e   ?   ' :   '   +   v a l u e . n a m e   :   ' ' ;   
             r e t u r n   c t x . s t y l i z e ( ' [ F u n c t i o n '   +   n a m e   +   ' ] ' ,   ' s p e c i a l ' ) ;   
         }   
         i f   ( i s R e g E x p ( v a l u e ) )   {   
             r e t u r n   c t x . s t y l i z e ( R e g E x p . p r o t o t y p e . t o S t r i n g . c a l l ( v a l u e ) ,   ' r e g e x p ' ) ;   
         }   
         i f   ( i s D a t e ( v a l u e ) )   {   
             i f   ( N u m b e r . i s N a N ( v a l u e . g e t T i m e ( ) ) )   {   
                 r e t u r n   c t x . s t y l i z e ( v a l u e . t o S t r i n g ( ) ,   ' d a t e ' ) ;   
             }   e l s e   {   
                 r e t u r n   c t x . s t y l i z e ( D a t e . p r o t o t y p e . t o I S O S t r i n g . c a l l ( v a l u e ) ,   ' d a t e ' ) ;   
             }   
         }   
         i f   ( i s E r r o r ( v a l u e ) )   {   
             r e t u r n   f o r m a t E r r o r ( v a l u e ) ;   
         }   
         / /   n o w   c h e c k   t h e   ` r a w `   v a l u e   t o   h a n d l e   b o x e d   p r i m i t i v e s   
         i f   ( t y p e o f   r a w   = = =   ' s t r i n g ' )   {   
             f o r m a t t e d   =   f o r m a t P r i m i t i v e N o C o l o r ( c t x ,   r a w ) ;   
             r e t u r n   c t x . s t y l i z e ( ' [ S t r i n g :   '   +   f o r m a t t e d   +   ' ] ' ,   ' s t r i n g ' ) ;   
         }   
         i f   ( t y p e o f   r a w   = = =   ' s y m b o l ' )   {   
             f o r m a t t e d   =   f o r m a t P r i m i t i v e N o C o l o r ( c t x ,   r a w ) ;   
             r e t u r n   c t x . s t y l i z e ( ' [ S y m b o l :   '   +   f o r m a t t e d   +   ' ] ' ,   ' s y m b o l ' ) ;   
         }   
         i f   ( t y p e o f   r a w   = = =   ' n u m b e r ' )   {   
             f o r m a t t e d   =   f o r m a t P r i m i t i v e N o C o l o r ( c t x ,   r a w ) ;   
             r e t u r n   c t x . s t y l i z e ( ' [ N u m b e r :   '   +   f o r m a t t e d   +   ' ] ' ,   ' n u m b e r ' ) ;   
         }   
         i f   ( t y p e o f   r a w   = = =   ' b o o l e a n ' )   {   
             f o r m a t t e d   =   f o r m a t P r i m i t i v e N o C o l o r ( c t x ,   r a w ) ;   
             r e t u r n   c t x . s t y l i z e ( ' [ B o o l e a n :   '   +   f o r m a t t e d   +   ' ] ' ,   ' b o o l e a n ' ) ;   
         }   
         / /   F a s t   p a t h   f o r   A r r a y B u f f e r .     C a n ' t   d o   t h e   s a m e   f o r   D a t a V i e w   b e c a u s e   i t   
         / /   h a s   a   n o n - p r i m i t i v e   . b u f f e r   p r o p e r t y   t h a t   w e   n e e d   t o   r e c u r s e   f o r .   
         i f   ( b i n d i n g . i s A r r a y B u f f e r ( v a l u e ) )   {   
             r e t u r n   ` $ { g e t C o n s t r u c t o r O f ( v a l u e ) . n a m e } `   +   
                           `   {   b y t e L e n g t h :   $ { f o r m a t N u m b e r ( c t x ,   v a l u e . b y t e L e n g t h ) }   } ` ;   
         }   
     }   
   
     v a r   c o n s t r u c t o r   =   g e t C o n s t r u c t o r O f ( v a l u e ) ;   
     v a r   b a s e   =   ' ' ,   e m p t y   =   f a l s e ,   b r a c e s ;   
     v a r   f o r m a t t e r   =   f o r m a t O b j e c t ;   
   
     / /   W e   c a n ' t   c o m p a r e   c o n s t r u c t o r s   f o r   v a r i o u s   o b j e c t s   u s i n g   a   c o m p a r i s o n   l i k e   
     / /   ` c o n s t r u c t o r   = = =   A r r a y `   b e c a u s e   t h e   o b j e c t   c o u l d   h a v e   c o m e   f r o m   a   d i f f e r e n t   
     / /   c o n t e x t   a n d   t h u s   t h e   c o n s t r u c t o r   w o n ' t   m a t c h .   I n s t e a d   w e   c h e c k   t h e   
     / /   c o n s t r u c t o r   n a m e s   ( i n c l u d i n g   t h o s e   u p   t h e   p r o t o t y p e   c h a i n   w h e r e   n e e d e d )   t o   
     / /   d e t e r m i n e   o b j e c t   t y p e s .   
     i f   ( A r r a y . i s A r r a y ( v a l u e ) )   {   
         / /   U n s e t   t h e   c o n s t r u c t o r   t o   p r e v e n t   " A r r a y   [ . . . ] "   f o r   o r d i n a r y   a r r a y s .   
         i f   ( c o n s t r u c t o r   & &   c o n s t r u c t o r . n a m e   = = =   ' A r r a y ' )   
             c o n s t r u c t o r   =   n u l l ;   
         b r a c e s   =   [ ' [ ' ,   ' ] ' ] ;   
         e m p t y   =   v a l u e . l e n g t h   = = =   0 ;   
         f o r m a t t e r   =   f o r m a t A r r a y ;   
     }   e l s e   i f   ( b i n d i n g . i s S e t ( v a l u e ) )   {   
         b r a c e s   =   [ ' { ' ,   ' } ' ] ;   
         / /   W i t h   ` s h o w H i d d e n ` ,   ` l e n g t h `   w i l l   d i s p l a y   a s   a   h i d d e n   p r o p e r t y   f o r   
         / /   a r r a y s .   F o r   c o n s i s t e n c y ' s   s a k e ,   d o   t h e   s a m e   f o r   ` s i z e ` ,   e v e n   t h o u g h   t h i s   
         / /   p r o p e r t y   i s n ' t   s e l e c t e d   b y   O b j e c t . g e t O w n P r o p e r t y N a m e s ( ) .   
         i f   ( c t x . s h o w H i d d e n )   
             k e y s . u n s h i f t ( ' s i z e ' ) ;   
         e m p t y   =   v a l u e . s i z e   = = =   0 ;   
         f o r m a t t e r   =   f o r m a t S e t ;   
     }   e l s e   i f   ( b i n d i n g . i s M a p ( v a l u e ) )   {   
         b r a c e s   =   [ ' { ' ,   ' } ' ] ;   
         / /   D i t t o .   
         i f   ( c t x . s h o w H i d d e n )   
             k e y s . u n s h i f t ( ' s i z e ' ) ;   
         e m p t y   =   v a l u e . s i z e   = = =   0 ;   
         f o r m a t t e r   =   f o r m a t M a p ;   
     }   e l s e   i f   ( b i n d i n g . i s A r r a y B u f f e r ( v a l u e ) )   {   
         b r a c e s   =   [ ' { ' ,   ' } ' ] ;   
         k e y s . u n s h i f t ( ' b y t e L e n g t h ' ) ;   
         v i s i b l e K e y s . b y t e L e n g t h   =   t r u e ;   
     }   e l s e   i f   ( b i n d i n g . i s D a t a V i e w ( v a l u e ) )   {   
         b r a c e s   =   [ ' { ' ,   ' } ' ] ;   
         / /   . b u f f e r   g o e s   l a s t ,   i t ' s   n o t   a   p r i m i t i v e   l i k e   t h e   o t h e r s .   
         k e y s . u n s h i f t ( ' b y t e L e n g t h ' ,   ' b y t e O f f s e t ' ,   ' b u f f e r ' ) ;   
         v i s i b l e K e y s . b y t e L e n g t h   =   t r u e ;   
         v i s i b l e K e y s . b y t e O f f s e t   =   t r u e ;   
         v i s i b l e K e y s . b u f f e r   =   t r u e ;   
     }   e l s e   i f   ( b i n d i n g . i s T y p e d A r r a y ( v a l u e ) )   {   
         b r a c e s   =   [ ' [ ' ,   ' ] ' ] ;   
         f o r m a t t e r   =   f o r m a t T y p e d A r r a y ;   
         i f   ( c t x . s h o w H i d d e n )   {   
             / /   . b u f f e r   g o e s   l a s t ,   i t ' s   n o t   a   p r i m i t i v e   l i k e   t h e   o t h e r s .   
             k e y s . u n s h i f t ( ' B Y T E S _ P E R _ E L E M E N T ' ,   
                                       ' l e n g t h ' ,   
                                       ' b y t e L e n g t h ' ,   
                                       ' b y t e O f f s e t ' ,   
                                       ' b u f f e r ' ) ;   
         }   
     }   e l s e   {   
         v a r   p r o m i s e I n t e r n a l s   =   i n s p e c t P r o m i s e ( v a l u e ) ;   
         i f   ( p r o m i s e I n t e r n a l s )   {   
             b r a c e s   =   [ ' { ' ,   ' } ' ] ;   
             f o r m a t t e r   =   f o r m a t P r o m i s e ;   
         }   e l s e   {   
             l e t   m a y b e S i m d F o r m a t t e r ;   
             i f   ( b i n d i n g . i s M a p I t e r a t o r ( v a l u e ) )   {   
                 c o n s t r u c t o r   =   {   n a m e :   ' M a p I t e r a t o r '   } ;   
                 b r a c e s   =   [ ' { ' ,   ' } ' ] ;   
                 e m p t y   =   f a l s e ;   
                 f o r m a t t e r   =   f o r m a t C o l l e c t i o n I t e r a t o r ;   
             }   e l s e   i f   ( b i n d i n g . i s S e t I t e r a t o r ( v a l u e ) )   {   
                 c o n s t r u c t o r   =   {   n a m e :   ' S e t I t e r a t o r '   } ;   
                 b r a c e s   =   [ ' { ' ,   ' } ' ] ;   
                 e m p t y   =   f a l s e ;   
                 f o r m a t t e r   =   f o r m a t C o l l e c t i o n I t e r a t o r ;   
             }   e l s e   i f   ( s i m d F o r m a t t e r s   & &   
                                   t y p e o f   c o n s t r u c t o r   = = =   ' f u n c t i o n '   & &   
                                   ( m a y b e S i m d F o r m a t t e r   =   s i m d F o r m a t t e r s . g e t ( c o n s t r u c t o r ) ) )   {   
                 b r a c e s   =   [ ' [ ' ,   ' ] ' ] ;   
                 f o r m a t t e r   =   m a y b e S i m d F o r m a t t e r ;   
             }   e l s e   {   
                 / /   U n s e t   t h e   c o n s t r u c t o r   t o   p r e v e n t   " O b j e c t   { . . . } "   f o r   o r d i n a r y   o b j e c t s .   
                 i f   ( c o n s t r u c t o r   & &   c o n s t r u c t o r . n a m e   = = =   ' O b j e c t ' )   
                     c o n s t r u c t o r   =   n u l l ;   
                 b r a c e s   =   [ ' { ' ,   ' } ' ] ;   
                 e m p t y   =   t r u e ;     / /   N o   o t h e r   d a t a   t h a n   k e y s .   
             }   
         }   
     }   
   
     e m p t y   =   e m p t y   = = =   t r u e   & &   k e y s . l e n g t h   = = =   0 ;   
   
     / /   M a k e   f u n c t i o n s   s a y   t h a t   t h e y   a r e   f u n c t i o n s   
     i f   ( t y p e o f   v a l u e   = = =   ' f u n c t i o n ' )   {   
         v a r   n   =   v a l u e . n a m e   ?   ' :   '   +   v a l u e . n a m e   :   ' ' ;   
         b a s e   =   '   [ F u n c t i o n '   +   n   +   ' ] ' ;   
     }   
   
     / /   M a k e   R e g E x p s   s a y   t h a t   t h e y   a r e   R e g E x p s   
     i f   ( i s R e g E x p ( v a l u e ) )   {   
         b a s e   =   '   '   +   R e g E x p . p r o t o t y p e . t o S t r i n g . c a l l ( v a l u e ) ;   
     }   
   
     / /   M a k e   d a t e s   w i t h   p r o p e r t i e s   f i r s t   s a y   t h e   d a t e   
     i f   ( i s D a t e ( v a l u e ) )   {   
         b a s e   =   '   '   +   D a t e . p r o t o t y p e . t o I S O S t r i n g . c a l l ( v a l u e ) ;   
     }   
   
     / /   M a k e   e r r o r   w i t h   m e s s a g e   f i r s t   s a y   t h e   e r r o r   
     i f   ( i s E r r o r ( v a l u e ) )   {   
         b a s e   =   '   '   +   f o r m a t E r r o r ( v a l u e ) ;   
     }   
   
     / /   M a k e   b o x e d   p r i m i t i v e   S t r i n g s   l o o k   l i k e   s u c h   
     i f   ( t y p e o f   r a w   = = =   ' s t r i n g ' )   {   
         f o r m a t t e d   =   f o r m a t P r i m i t i v e N o C o l o r ( c t x ,   r a w ) ;   
         b a s e   =   '   '   +   ' [ S t r i n g :   '   +   f o r m a t t e d   +   ' ] ' ;   
     }   
   
     / /   M a k e   b o x e d   p r i m i t i v e   N u m b e r s   l o o k   l i k e   s u c h   
     i f   ( t y p e o f   r a w   = = =   ' n u m b e r ' )   {   
         f o r m a t t e d   =   f o r m a t P r i m i t i v e N o C o l o r ( c t x ,   r a w ) ;   
         b a s e   =   '   '   +   ' [ N u m b e r :   '   +   f o r m a t t e d   +   ' ] ' ;   
     }   
   
     / /   M a k e   b o x e d   p r i m i t i v e   B o o l e a n s   l o o k   l i k e   s u c h   
     i f   ( t y p e o f   r a w   = = =   ' b o o l e a n ' )   {   
         f o r m a t t e d   =   f o r m a t P r i m i t i v e N o C o l o r ( c t x ,   r a w ) ;   
         b a s e   =   '   '   +   ' [ B o o l e a n :   '   +   f o r m a t t e d   +   ' ] ' ;   
     }   
   
     / /   A d d   c o n s t r u c t o r   n a m e   i f   a v a i l a b l e   
     i f   ( b a s e   = = =   ' '   & &   c o n s t r u c t o r )   
         b r a c e s [ 0 ]   =   c o n s t r u c t o r . n a m e   +   '   '   +   b r a c e s [ 0 ] ;   
   
     i f   ( e m p t y   = = =   t r u e )   {   
         r e t u r n   b r a c e s [ 0 ]   +   b a s e   +   b r a c e s [ 1 ] ;   
     }   
   
     i f   ( r e c u r s e T i m e s   <   0 )   {   
         i f   ( i s R e g E x p ( v a l u e ) )   {   
             r e t u r n   c t x . s t y l i z e ( R e g E x p . p r o t o t y p e . t o S t r i n g . c a l l ( v a l u e ) ,   ' r e g e x p ' ) ;   
         }   e l s e   {   
             r e t u r n   c t x . s t y l i z e ( ' [ O b j e c t ] ' ,   ' s p e c i a l ' ) ;   
         }   
     }   
   
     c t x . s e e n . p u s h ( v a l u e ) ;   
   
     v a r   o u t p u t   =   f o r m a t t e r ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y s ) ;   
   
     c t x . s e e n . p o p ( ) ;   
   
     r e t u r n   r e d u c e T o S i n g l e S t r i n g ( o u t p u t ,   b a s e ,   b r a c e s ,   c t x . b r e a k L e n g t h ) ;   
 }   
   
   
 f u n c t i o n   f o r m a t N u m b e r ( c t x ,   v a l u e )   {   
     / /   F o r m a t   - 0   a s   ' - 0 ' .   S t r i c t   e q u a l i t y   w o n ' t   d i s t i n g u i s h   0   f r o m   - 0 ,   
     / /   s o   i n s t e a d   w e   u s e   t h e   f a c t   t h a t   1   /   - 0   <   0   w h e r e a s   1   /   0   >   0   .   
     i f   ( v a l u e   = = =   0   & &   1   /   v a l u e   <   0 )   
         r e t u r n   c t x . s t y l i z e ( ' - 0 ' ,   ' n u m b e r ' ) ;   
     r e t u r n   c t x . s t y l i z e ( ' '   +   v a l u e ,   ' n u m b e r ' ) ;   
 }   
   
   
 f u n c t i o n   f o r m a t P r i m i t i v e ( c t x ,   v a l u e )   {   
     i f   ( v a l u e   = = =   u n d e f i n e d )   
         r e t u r n   c t x . s t y l i z e ( ' u n d e f i n e d ' ,   ' u n d e f i n e d ' ) ;   
   
     / /   F o r   s o m e   r e a s o n   t y p e o f   n u l l   i s   " o b j e c t " ,   s o   s p e c i a l   c a s e   h e r e .   
     i f   ( v a l u e   = = =   n u l l )   
         r e t u r n   c t x . s t y l i z e ( ' n u l l ' ,   ' n u l l ' ) ;   
   
     v a r   t y p e   =   t y p e o f   v a l u e ;   
   
     i f   ( t y p e   = = =   ' s t r i n g ' )   {   
         v a r   s i m p l e   =   ' \ ' '   +   
                                   J S O N . s t r i n g i f y ( v a l u e )   
                                           . r e p l a c e ( / ^ " | " $ / g ,   ' ' )   
                                           . r e p l a c e ( / ' / g ,   " \ \ ' " )   
                                           . r e p l a c e ( / \ \ " / g ,   ' " ' )   +   
                                   ' \ ' ' ;   
         r e t u r n   c t x . s t y l i z e ( s i m p l e ,   ' s t r i n g ' ) ;   
     }   
     i f   ( t y p e   = = =   ' n u m b e r ' )   
         r e t u r n   f o r m a t N u m b e r ( c t x ,   v a l u e ) ;   
     i f   ( t y p e   = = =   ' b o o l e a n ' )   
         r e t u r n   c t x . s t y l i z e ( ' '   +   v a l u e ,   ' b o o l e a n ' ) ;   
     / /   e s 6   s y m b o l   p r i m i t i v e   
     i f   ( t y p e   = = =   ' s y m b o l ' )   
         r e t u r n   c t x . s t y l i z e ( v a l u e . t o S t r i n g ( ) ,   ' s y m b o l ' ) ;   
 }   
   
   
 f u n c t i o n   f o r m a t P r i m i t i v e N o C o l o r ( c t x ,   v a l u e )   {   
     v a r   s t y l i z e   =   c t x . s t y l i z e ;   
     c t x . s t y l i z e   =   s t y l i z e N o C o l o r ;   
     v a r   s t r   =   f o r m a t P r i m i t i v e ( c t x ,   v a l u e ) ;   
     c t x . s t y l i z e   =   s t y l i z e ;   
     r e t u r n   s t r ;   
 }   
   
   
 f u n c t i o n   f o r m a t E r r o r ( v a l u e )   {   
     r e t u r n   v a l u e . s t a c k   | |   ' [ '   +   E r r o r . p r o t o t y p e . t o S t r i n g . c a l l ( v a l u e )   +   ' ] ' ;   
 }   
   
   
 f u n c t i o n   f o r m a t O b j e c t ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y s )   {   
     r e t u r n   k e y s . m a p ( f u n c t i o n ( k e y )   {   
         r e t u r n   f o r m a t P r o p e r t y ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y ,   f a l s e ) ;   
     } ) ;   
 }   
   
   
 f u n c t i o n   f o r m a t A r r a y ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y s )   {   
     v a r   o u t p u t   =   [ ] ;   
     c o n s t   m a x L e n g t h   =   M a t h . m i n ( M a t h . m a x ( 0 ,   c t x . m a x A r r a y L e n g t h ) ,   v a l u e . l e n g t h ) ;   
     c o n s t   r e m a i n i n g   =   v a l u e . l e n g t h   -   m a x L e n g t h ;   
     f o r   ( v a r   i   =   0 ;   i   <   m a x L e n g t h ;   + + i )   {   
         i f   ( h a s O w n P r o p e r t y ( v a l u e ,   S t r i n g ( i ) ) )   {   
             o u t p u t . p u s h ( f o r m a t P r o p e r t y ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   
                     S t r i n g ( i ) ,   t r u e ) ) ;   
         }   e l s e   {   
             o u t p u t . p u s h ( ' ' ) ;   
         }   
     }   
     i f   ( r e m a i n i n g   >   0 )   {   
         o u t p u t . p u s h ( ` . . .   $ { r e m a i n i n g }   m o r e   i t e m $ { r e m a i n i n g   >   1   ?   ' s '   :   ' ' } ` ) ;   
     }   
     k e y s . f o r E a c h ( f u n c t i o n ( k e y )   {   
         i f   ( t y p e o f   k e y   = = =   ' s y m b o l '   | |   ! k e y . m a t c h ( / ^ \ d + $ / ) )   {   
             o u t p u t . p u s h ( f o r m a t P r o p e r t y ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   
                     k e y ,   t r u e ) ) ;   
         }   
     } ) ;   
     r e t u r n   o u t p u t ;   
 }   
   
   
 f u n c t i o n   f o r m a t T y p e d A r r a y ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y s )   {   
     c o n s t   m a x L e n g t h   =   M a t h . m i n ( M a t h . m a x ( 0 ,   c t x . m a x A r r a y L e n g t h ) ,   v a l u e . l e n g t h ) ;   
     c o n s t   r e m a i n i n g   =   v a l u e . l e n g t h   -   m a x L e n g t h ;   
     v a r   o u t p u t   =   n e w   A r r a y ( m a x L e n g t h ) ;   
     f o r   ( v a r   i   =   0 ;   i   <   m a x L e n g t h ;   + + i )   
         o u t p u t [ i ]   =   f o r m a t N u m b e r ( c t x ,   v a l u e [ i ] ) ;   
     i f   ( r e m a i n i n g   >   0 )   {   
         o u t p u t . p u s h ( ` . . .   $ { r e m a i n i n g }   m o r e   i t e m $ { r e m a i n i n g   >   1   ?   ' s '   :   ' ' } ` ) ;   
     }   
     f o r   ( l e t   k e y   o f   k e y s )   {   
         i f   ( t y p e o f   k e y   = = =   ' s y m b o l '   | |   ! k e y . m a t c h ( / ^ \ d + $ / ) )   {   
             o u t p u t . p u s h (   
                     f o r m a t P r o p e r t y ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y ,   t r u e ) ) ;   
         }   
     }   
     r e t u r n   o u t p u t ;   
 }   
   
   
 f u n c t i o n   f o r m a t S e t ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y s )   {   
     v a r   o u t p u t   =   [ ] ;   
     v a l u e . f o r E a c h ( f u n c t i o n ( v )   {   
         v a r   n e x t R e c u r s e T i m e s   =   r e c u r s e T i m e s   = = =   n u l l   ?   n u l l   :   r e c u r s e T i m e s   -   1 ;   
         v a r   s t r   =   f o r m a t V a l u e ( c t x ,   v ,   n e x t R e c u r s e T i m e s ) ;   
         o u t p u t . p u s h ( s t r ) ;   
     } ) ;   
     k e y s . f o r E a c h ( f u n c t i o n ( k e y )   {   
         o u t p u t . p u s h ( f o r m a t P r o p e r t y ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   
                                                               k e y ,   f a l s e ) ) ;   
     } ) ;   
     r e t u r n   o u t p u t ;   
 }   
   
   
 f u n c t i o n   f o r m a t M a p ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y s )   {   
     v a r   o u t p u t   =   [ ] ;   
     v a l u e . f o r E a c h ( f u n c t i o n ( v ,   k )   {   
         v a r   n e x t R e c u r s e T i m e s   =   r e c u r s e T i m e s   = = =   n u l l   ?   n u l l   :   r e c u r s e T i m e s   -   1 ;   
         v a r   s t r   =   f o r m a t V a l u e ( c t x ,   k ,   n e x t R e c u r s e T i m e s ) ;   
         s t r   + =   '   = >   ' ;   
         s t r   + =   f o r m a t V a l u e ( c t x ,   v ,   n e x t R e c u r s e T i m e s ) ;   
         o u t p u t . p u s h ( s t r ) ;   
     } ) ;   
     k e y s . f o r E a c h ( f u n c t i o n ( k e y )   {   
         o u t p u t . p u s h ( f o r m a t P r o p e r t y ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   
                                                               k e y ,   f a l s e ) ) ;   
     } ) ;   
     r e t u r n   o u t p u t ;   
 }   
   
 f u n c t i o n   f o r m a t C o l l e c t i o n I t e r a t o r ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y s )   {   
     e n s u r e D e b u g I s I n i t i a l i z e d ( ) ;   
     c o n s t   m i r r o r   =   D e b u g . M a k e M i r r o r ( v a l u e ,   t r u e ) ;   
     v a r   n e x t R e c u r s e T i m e s   =   r e c u r s e T i m e s   = = =   n u l l   ?   n u l l   :   r e c u r s e T i m e s   -   1 ;   
     v a r   v a l s   =   m i r r o r . p r e v i e w ( ) ;   
     v a r   o u t p u t   =   [ ] ;   
     f o r   ( l e t   o   o f   v a l s )   {   
         o u t p u t . p u s h ( f o r m a t V a l u e ( c t x ,   o ,   n e x t R e c u r s e T i m e s ) ) ;   
     }   
     r e t u r n   o u t p u t ;   
 }   
   
 f u n c t i o n   f o r m a t P r o m i s e ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y s )   {   
     v a r   o u t p u t   =   [ ] ;   
     v a r   i n t e r n a l s   =   i n s p e c t P r o m i s e ( v a l u e ) ;   
     i f   ( i n t e r n a l s . s t a t u s   = = =   ' p e n d i n g ' )   {   
         o u t p u t . p u s h ( ' < p e n d i n g > ' ) ;   
     }   e l s e   {   
         v a r   n e x t R e c u r s e T i m e s   =   r e c u r s e T i m e s   = = =   n u l l   ?   n u l l   :   r e c u r s e T i m e s   -   1 ;   
         v a r   s t r   =   f o r m a t V a l u e ( c t x ,   i n t e r n a l s . v a l u e ,   n e x t R e c u r s e T i m e s ) ;   
         i f   ( i n t e r n a l s . s t a t u s   = = =   ' r e j e c t e d ' )   {   
             o u t p u t . p u s h ( ' < r e j e c t e d >   '   +   s t r ) ;   
         }   e l s e   {   
             o u t p u t . p u s h ( s t r ) ;   
         }   
     }   
     k e y s . f o r E a c h ( f u n c t i o n ( k e y )   {   
         o u t p u t . p u s h ( f o r m a t P r o p e r t y ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   
                                                               k e y ,   f a l s e ) ) ;   
     } ) ;   
     r e t u r n   o u t p u t ;   
 }   
   
   
 f u n c t i o n   f o r m a t P r o p e r t y ( c t x ,   v a l u e ,   r e c u r s e T i m e s ,   v i s i b l e K e y s ,   k e y ,   a r r a y )   {   
     v a r   n a m e ,   s t r ,   d e s c ;   
     d e s c   =   O b j e c t . g e t O w n P r o p e r t y D e s c r i p t o r ( v a l u e ,   k e y )   | |   {   v a l u e :   v a l u e [ k e y ]   } ;   
     i f   ( d e s c . g e t )   {   
         i f   ( d e s c . s e t )   {   
             s t r   =   c t x . s t y l i z e ( ' [ G e t t e r / S e t t e r ] ' ,   ' s p e c i a l ' ) ;   
         }   e l s e   {   
             s t r   =   c t x . s t y l i z e ( ' [ G e t t e r ] ' ,   ' s p e c i a l ' ) ;   
         }   
     }   e l s e   {   
         i f   ( d e s c . s e t )   {   
             s t r   =   c t x . s t y l i z e ( ' [ S e t t e r ] ' ,   ' s p e c i a l ' ) ;   
         }   
     }   
     i f   ( ! h a s O w n P r o p e r t y ( v i s i b l e K e y s ,   k e y ) )   {   
         i f   ( t y p e o f   k e y   = = =   ' s y m b o l ' )   {   
             n a m e   =   ' [ '   +   c t x . s t y l i z e ( k e y . t o S t r i n g ( ) ,   ' s y m b o l ' )   +   ' ] ' ;   
         }   e l s e   {   
             n a m e   =   ' [ '   +   k e y   +   ' ] ' ;   
         }   
     }   
     i f   ( ! s t r )   {   
         i f   ( c t x . s e e n . i n d e x O f ( d e s c . v a l u e )   <   0 )   {   
             i f   ( r e c u r s e T i m e s   = = =   n u l l )   {   
                 s t r   =   f o r m a t V a l u e ( c t x ,   d e s c . v a l u e ,   n u l l ) ;   
             }   e l s e   {   
                 s t r   =   f o r m a t V a l u e ( c t x ,   d e s c . v a l u e ,   r e c u r s e T i m e s   -   1 ) ;   
             }   
             i f   ( s t r . i n d e x O f ( ' \ n ' )   >   - 1 )   {   
                 i f   ( a r r a y )   {   
                     s t r   =   s t r . r e p l a c e ( / \ n / g ,   ' \ n     ' ) ;   
                 }   e l s e   {   
                     s t r   =   s t r . r e p l a c e ( / ( ^ | \ n ) / g ,   ' \ n       ' ) ;   
                 }   
             }   
         }   e l s e   {   
             s t r   =   c t x . s t y l i z e ( ' [ C i r c u l a r ] ' ,   ' s p e c i a l ' ) ;   
         }   
     }   
     i f   ( n a m e   = = =   u n d e f i n e d )   {   
         i f   ( a r r a y   & &   k e y . m a t c h ( / ^ \ d + $ / ) )   {   
             r e t u r n   s t r ;   
         }   
         n a m e   =   J S O N . s t r i n g i f y ( ' '   +   k e y ) ;   
         i f   ( n a m e . m a t c h ( / ^ " ( [ a - z A - Z _ ] [ a - z A - Z _ 0 - 9 ] * ) " $ / ) )   {   
             n a m e   =   n a m e . s u b s t r ( 1 ,   n a m e . l e n g t h   -   2 ) ;   
             n a m e   =   c t x . s t y l i z e ( n a m e ,   ' n a m e ' ) ;   
         }   e l s e   {   
             n a m e   =   n a m e . r e p l a c e ( / ' / g ,   " \ \ ' " )   
                                   . r e p l a c e ( / \ \ " / g ,   ' " ' )   
                                   . r e p l a c e ( / ( ^ " | " $ ) / g ,   " ' " )   
                                   . r e p l a c e ( / \ \ \ \ / g ,   ' \ \ ' ) ;   
             n a m e   =   c t x . s t y l i z e ( n a m e ,   ' s t r i n g ' ) ;   
         }   
     }   
   
     r e t u r n   n a m e   +   ' :   '   +   s t r ;   
 }   
   
   
 f u n c t i o n   r e d u c e T o S i n g l e S t r i n g ( o u t p u t ,   b a s e ,   b r a c e s ,   b r e a k L e n g t h )   {   
     v a r   l e n g t h   =   o u t p u t . r e d u c e ( f u n c t i o n ( p r e v ,   c u r )   {   
         r e t u r n   p r e v   +   c u r . r e p l a c e ( / \ u 0 0 1 b \ [ \ d \ d ? m / g ,   ' ' ) . l e n g t h   +   1 ;   
     } ,   0 ) ;   
   
     i f   ( l e n g t h   >   b r e a k L e n g t h )   {   
         r e t u r n   b r a c e s [ 0 ]   +   
                       / /   I f   t h e   o p e n i n g   " b r a c e "   i s   t o o   l a r g e ,   l i k e   i n   t h e   c a s e   o f   " S e t   { " ,   
                       / /   w e   n e e d   t o   f o r c e   t h e   f i r s t   i t e m   t o   b e   o n   t h e   n e x t   l i n e   o r   t h e   
                       / /   i t e m s   w i l l   n o t   l i n e   u p   c o r r e c t l y .   
                       ( b a s e   = = =   ' '   & &   b r a c e s [ 0 ] . l e n g t h   = = =   1   ?   ' '   :   b a s e   +   ' \ n   ' )   +   
                       '   '   +   
                       o u t p u t . j o i n ( ' , \ n     ' )   +   
                       '   '   +   
                       b r a c e s [ 1 ] ;   
     }   
   
     r e t u r n   b r a c e s [ 0 ]   +   b a s e   +   '   '   +   o u t p u t . j o i n ( ' ,   ' )   +   '   '   +   b r a c e s [ 1 ] ;   
 }   
   
   
 / /   N O T E :   T h e s e   t y p e   c h e c k i n g   f u n c t i o n s   i n t e n t i o n a l l y   d o n ' t   u s e   ` i n s t a n c e o f `   
 / /   b e c a u s e   i t   i s   f r a g i l e   a n d   c a n   b e   e a s i l y   f a k e d   w i t h   ` O b j e c t . c r e a t e ( ) ` .   
 / * *   
   *   
   *   @ p a r a m   a r   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 e x p o r t s . i s A r r a y   =   A r r a y . i s A r r a y ;   
   
 / * *   
   *   
   *   @ p a r a m   a r g   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 f u n c t i o n   i s B o o l e a n ( a r g )   {   
     r e t u r n   t y p e o f   a r g   = = =   ' b o o l e a n ' ;   
 }   
 e x p o r t s . i s B o o l e a n   =   i s B o o l e a n ;   
   
 / * *   
   *   
   *   @ p a r a m   a r g   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 f u n c t i o n   i s N u l l ( a r g )   {   
     r e t u r n   a r g   = = =   n u l l ;   
 }   
 e x p o r t s . i s N u l l   =   i s N u l l ;   
   
 / * *   
   *   
   *   @ p a r a m   a r g   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 f u n c t i o n   i s N u l l O r U n d e f i n e d ( a r g )   {   
     r e t u r n   a r g   = = =   n u l l   | |   a r g   = = =   u n d e f i n e d ;   
 }   
 e x p o r t s . i s N u l l O r U n d e f i n e d   =   i s N u l l O r U n d e f i n e d ;   
   
 / * *   
   *   
   *   @ p a r a m   a r g   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 f u n c t i o n   i s N u m b e r ( a r g )   {   
     r e t u r n   t y p e o f   a r g   = = =   ' n u m b e r ' ;   
 }   
 e x p o r t s . i s N u m b e r   =   i s N u m b e r ;   
   
 / * *   
   *   
   *   @ p a r a m   a r g   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 f u n c t i o n   i s S t r i n g ( a r g )   {   
     r e t u r n   t y p e o f   a r g   = = =   ' s t r i n g ' ;   
 }   
 e x p o r t s . i s S t r i n g   =   i s S t r i n g ;   
   
 / * *   
   *   
   *   @ p a r a m   a r g   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 f u n c t i o n   i s S y m b o l ( a r g )   {   
     r e t u r n   t y p e o f   a r g   = = =   ' s y m b o l ' ;   
 }   
 e x p o r t s . i s S y m b o l   =   i s S y m b o l ;   
   
 / * *   
   *   
   *   @ p a r a m   a r g   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 f u n c t i o n   i s U n d e f i n e d ( a r g )   {   
     r e t u r n   a r g   = = =   u n d e f i n e d ;   
 }   
 e x p o r t s . i s U n d e f i n e d   =   i s U n d e f i n e d ;   
   
 / * *   
   *   
   *   @ p a r a m   r e   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 f u n c t i o n   i s R e g E x p ( r e )   {   
     r e t u r n   b i n d i n g . i s R e g E x p ( r e ) ;   
 }   
 e x p o r t s . i s R e g E x p   =   i s R e g E x p ;   
   
 / * *   
   *   
   *   @ p a r a m   a r g   
   *   @ r e t u r n   { b o o l e a n }   
   * /   
 f u n c t i o n   i s O b j e c t ( a r g )   {   
     r e t u r n   a r g   ! = =   n u l l   & &   t y p e o f   a r g   = = =   ' o b j e c t ' ;   
 }   
 e x p o r t s . i s O b j e c t   =   i s O b j e c t ;   
   
 / * *   
   *   
   *   @ p a r a m   d   
   *   @ r e t u r n s   { b o o l e a n }   
   * /   
 f u n c t i o n   i s D a t e ( d )   {   
     r e t u r n   b i n d i n g . i s D a t e ( d ) ;   
 }   
 e x p o r t s . i s D a t e   =   i s D a t e ;   
   
 / * *   
   *   
   *   @ p a r a m   e   
   *   @ r e t u r n s   { b o o l e a n }   
   * /   
 e x p o r t s . i s E r r o r   =   i s E r r o r ;   
   
 / * *   
   *   
   *   @ p a r a m   a r g   
   *   @ r e t u r n s   { b o o l e a n }   
   * /   
 f u n c t i o n   i s F u n c t i o n ( a r g )   {   
     r e t u r n   t y p e o f   a r g   = = =   ' f u n c t i o n ' ;   
 }   
 e x p o r t s . i s F u n c t i o n   =   i s F u n c t i o n ;   
   
 / * *   
   *   
   *   @ p a r a m   a r g   
   *   @ r e t u r n s   { b o o l e a n }   
   * /   
 f u n c t i o n   i s P r i m i t i v e ( a r g )   {   
     r e t u r n   a r g   = = =   n u l l   | |   
                   t y p e o f   a r g   ! = =   ' o b j e c t '   & &   t y p e o f   a r g   ! = =   ' f u n c t i o n ' ;   
 }   
 e x p o r t s . i s P r i m i t i v e   =   i s P r i m i t i v e ;   
   
 / * *   
   *   
   *   @ p a r a m   b   
   *   @ r e t u r n s   { b o o l e a n }   
   * /   
 e x p o r t s . i s B u f f e r   =   B u f f e r . i s B u f f e r ;   
   
 f u n c t i o n   p a d ( n )   {   
     r e t u r n   n   <   1 0   ?   ' 0 '   +   n . t o S t r i n g ( 1 0 )   :   n . t o S t r i n g ( 1 0 ) ;   
 }   
   
   
 c o n s t   m o n t h s   =   [ ' J a n ' ,   ' F e b ' ,   ' M a r ' ,   ' A p r ' ,   ' M a y ' ,   ' J u n ' ,   ' J u l ' ,   ' A u g ' ,   ' S e p ' ,   
                                 ' O c t ' ,   ' N o v ' ,   ' D e c ' ] ;   
   
 / /   2 6   F e b   1 6 : 1 9 : 3 4   
 f u n c t i o n   t i m e s t a m p ( )   {   
     v a r   d   =   n e w   D a t e ( ) ;   
     v a r   t i m e   =   [ p a d ( d . g e t H o u r s ( ) ) ,   
                             p a d ( d . g e t M i n u t e s ( ) ) ,   
                             p a d ( d . g e t S e c o n d s ( ) ) ] . j o i n ( ' : ' ) ;   
     r e t u r n   [ d . g e t D a t e ( ) ,   m o n t h s [ d . g e t M o n t h ( ) ] ,   t i m e ] . j o i n ( '   ' ) ;   
 }   
   
   
 / /   l o g   i s   j u s t   a   t h i n   w r a p p e r   t o   c o n s o l e . l o g   t h a t   p r e p e n d s   a   t i m e s t a m p   
 / * *   
   *   O u t p u t   w i t h   t i m e s t a m p   o n   s t d o u t .   
   *   @ p a r a m   { S t r i n g }   m s g   
   * /   
 e x p o r t s . l o g   =   f u n c t i o n ( )   {   
     c o n s o l e . l o g ( ' % s   -   % s ' ,   t i m e s t a m p ( ) ,   e x p o r t s . f o r m a t . a p p l y ( e x p o r t s ,   a r g u m e n t s ) ) ;   
 } ;   
   
   
 / * *   
   *   I n h e r i t   t h e   p r o t o t y p e   m e t h o d s   f r o m   o n e   c o n s t r u c t o r   i n t o   a n o t h e r .   
   *   
   *   T h e   F u n c t i o n . p r o t o t y p e . i n h e r i t s   f r o m   l a n g . j s   r e w r i t t e n   a s   a   s t a n d a l o n e   
   *   f u n c t i o n   ( n o t   o n   F u n c t i o n . p r o t o t y p e ) .   N O T E :   I f   t h i s   f i l e   i s   t o   b e   l o a d e d   
   *   d u r i n g   b o o t s t r a p p i n g   t h i s   f u n c t i o n   n e e d s   t o   b e   r e w r i t t e n   u s i n g   s o m e   n a t i v e   
   *   f u n c t i o n s   a s   p r o t o t y p e   s e t u p   u s i n g   n o r m a l   J a v a S c r i p t   d o e s   n o t   w o r k   a s   
   *   e x p e c t e d   d u r i n g   b o o t s t r a p p i n g   ( s e e   m i r r o r . j s   i n   r 1 1 4 9 0 3 ) .   
   *   
   *   @ p a r a m   { f u n c t i o n }   c t o r   C o n s t r u c t o r   f u n c t i o n   w h i c h   n e e d s   t o   i n h e r i t   t h e   
   *           p r o t o t y p e .   
   *   @ p a r a m   { f u n c t i o n }   s u p e r C t o r   C o n s t r u c t o r   f u n c t i o n   t o   i n h e r i t   p r o t o t y p e   f r o m .   
   *   @ t h r o w s   { T y p e E r r o r }   W i l l   e r r o r   i f   e i t h e r   c o n s t r u c t o r   i s   n u l l ,   o r   i f   
   *           t h e   s u p e r   c o n s t r u c t o r   l a c k s   a   p r o t o t y p e .   
   * /   
 e x p o r t s . i n h e r i t s   =   f u n c t i o n ( c t o r ,   s u p e r C t o r )   {   
   
     i f   ( c t o r   = = =   u n d e f i n e d   | |   c t o r   = = =   n u l l )   
         t h r o w   n e w   T y p e E r r o r ( ' T h e   c o n s t r u c t o r   t o   " i n h e r i t s "   m u s t   n o t   b e   '   +   
                                                 ' n u l l   o r   u n d e f i n e d ' ) ;   
   
     i f   ( s u p e r C t o r   = = =   u n d e f i n e d   | |   s u p e r C t o r   = = =   n u l l )   
         t h r o w   n e w   T y p e E r r o r ( ' T h e   s u p e r   c o n s t r u c t o r   t o   " i n h e r i t s "   m u s t   n o t   '   +   
                                                 ' b e   n u l l   o r   u n d e f i n e d ' ) ;   
   
     i f   ( s u p e r C t o r . p r o t o t y p e   = = =   u n d e f i n e d )   
         t h r o w   n e w   T y p e E r r o r ( ' T h e   s u p e r   c o n s t r u c t o r   t o   " i n h e r i t s "   m u s t   '   +   
                                                 ' h a v e   a   p r o t o t y p e ' ) ;   
   
     c t o r . s u p e r _   =   s u p e r C t o r ;   
     O b j e c t . s e t P r o t o t y p e O f ( c t o r . p r o t o t y p e ,   s u p e r C t o r . p r o t o t y p e ) ;   
 } ;   
   
 e x p o r t s . _ e x t e n d   =   f u n c t i o n ( t a r g e t ,   s o u r c e )   {   
     / /   D o n ' t   d o   a n y t h i n g   i f   s o u r c e   i s n ' t   a n   o b j e c t   
     i f   ( s o u r c e   = = =   n u l l   | |   t y p e o f   s o u r c e   ! = =   ' o b j e c t ' )   r e t u r n   t a r g e t ;   
   
     v a r   k e y s   =   O b j e c t . k e y s ( s o u r c e ) ;   
     v a r   i   =   k e y s . l e n g t h ;   
     w h i l e   ( i - - )   {   
         t a r g e t [ k e y s [ i ] ]   =   s o u r c e [ k e y s [ i ] ] ;   
     }   
     r e t u r n   t a r g e t ;   
 } ;   
   
 f u n c t i o n   h a s O w n P r o p e r t y ( o b j ,   p r o p )   {   
     r e t u r n   O b j e c t . p r o t o t y p e . h a s O w n P r o p e r t y . c a l l ( o b j ,   p r o p ) ;   
 }   
   
   
 / /   D e p r e c a t e d   o l d   s t u f f .   
 / * *   
   *   A   s y n c h r o n o u s   o u t p u t   f u n c t i o n .   W i l l   b l o c k   t h e   p r o c e s s ,   c a s t   e a c h   a r g u m e n t   t o   a   s t r i n g   t h e n   o u t p u t   t o   s t d o u t .   D o e s   n o t   p l a c e   n e w l i n e s   a f t e r   e a c h   a r g u m e n t :   
   *   
   *             u t i l . p r i n t ( ' o n e ' ,   ' t w o ' ,   3 ) ;   / /   o n e t w o 3   
   *   
   *   @ m e t h o d   p r i n t   
   *   @ d e p r e c a t e d   U s e   { @ l i n k   c o n s o l e . l o g }   i n s t e a d   
   *   @ p a r a m   { . . . * }   a r g u m e n t s   
   * /   
 e x p o r t s . p r i n t   =   i n t e r n a l U t i l . d e p r e c a t e ( f u n c t i o n ( )   {   
     f o r   ( v a r   i   =   0 ,   l e n   =   a r g u m e n t s . l e n g t h ;   i   <   l e n ;   + + i )   {   
         p r o c e s s . s t d o u t . w r i t e ( S t r i n g ( a r g u m e n t s [ i ] ) ) ;   
     }   
 } ,   ' u t i l . p r i n t   i s   d e p r e c a t e d .   U s e   c o n s o l e . l o g   i n s t e a d . ' ) ;   
   
 / * *   
   *     A   s y n c h r o n o u s   o u t p u t   f u n c t i o n .   W i l l   b l o c k   t h e   p r o c e s s   a n d   o u t p u t   a l l   a r g u m e n t s   t o   s t d o u t   w i t h   n e w l i n e s   a f t e r   e a c h   a r g u m e n t .   
   *   
   *             u t i l . p u t s ( ' o n e ' ,   ' t w o ' ,   3 ) ;   / /   o n e   
   *                                                                     / /   t w o   
   *                                                                     / /   3   
   *   @ m e t h o d   p u t s   
   *   @ d e p r e c a t e d   U s e   { @ l i n k   c o n s o l e . l o g }   i n s t e a d   
   *   @ p a r a m   { . . . * }   a r g u m e n t s   
   * /   
 e x p o r t s . p u t s   =   i n t e r n a l U t i l . d e p r e c a t e ( f u n c t i o n ( )   {   
     f o r   ( v a r   i   =   0 ,   l e n   =   a r g u m e n t s . l e n g t h ;   i   <   l e n ;   + + i )   {   
         p r o c e s s . s t d o u t . w r i t e ( a r g u m e n t s [ i ]   +   ' \ n ' ) ;   
     }   
 } ,   ' u t i l . p u t s   i s   d e p r e c a t e d .   U s e   c o n s o l e . l o g   i n s t e a d . ' ) ;   
   
 / * *   
   *   W i l l   b l o c k   t h e   p r o c e s s   a n d   o u t p u t   s t r i n g   i m m e d i a t e l y   t o   s t d e r r :   
   *   
   *             r e q u i r e ( ' u t i l ' ) . d e b u g ( ' m e s s a g e   o n   s t d e r r ' ) ;   
   *   
   *   @ m e t h o d   d e b u g   
   *   @ d e p r e c a t e d   U s e   { @ l i n k   c o n s o l e . e r r o r }   i n s t e a d   
   *   @ p a r a m   { * }   m s g   
   * /   
 e x p o r t s . d e b u g   =   i n t e r n a l U t i l . d e p r e c a t e ( f u n c t i o n ( x )   {   
     p r o c e s s . s t d e r r . w r i t e ( ' D E B U G :   '   +   x   +   ' \ n ' ) ;   
 } ,   ' u t i l . d e b u g   i s   d e p r e c a t e d .   U s e   c o n s o l e . e r r o r   i n s t e a d . ' ) ;   
   
   
   
 / * *   
   *   S a m e   a s   { @ l i n k   u t i l # d e b u g }   e x c e p t   t h i s   w i l l   o u t p u t   * a l l *   a r g u m e n t s   i m m e d i a t e l y   t o   s t d e r r .   
   *   
   *   @ m e t h o d   e r r o r   
   *   @ d e p r e c a t e d   U s e   { @ l i n k   c o n s o l e . e r r o r }   i n s t e a d   
   *   @ p a r a m   { . . . * }   a r g u m e n t s   
   * /   
 e x p o r t s . e r r o r   =   i n t e r n a l U t i l . d e p r e c a t e ( f u n c t i o n ( x )   {   
     f o r   ( v a r   i   =   0 ,   l e n   =   a r g u m e n t s . l e n g t h ;   i   <   l e n ;   + + i )   {   
         p r o c e s s . s t d e r r . w r i t e ( a r g u m e n t s [ i ]   +   ' \ n ' ) ;   
     }   
 } ,   ' u t i l . e r r o r   i s   d e p r e c a t e d .   U s e   c o n s o l e . e r r o r   i n s t e a d . ' ) ;   
   
   
 e x p o r t s . _ e r r n o E x c e p t i o n   =   f u n c t i o n ( e r r ,   s y s c a l l ,   o r i g i n a l )   {   
     v a r   e r r n a m e   =   u v . e r r n a m e ( e r r ) ;   
     v a r   m e s s a g e   =   s y s c a l l   +   '   '   +   e r r n a m e ;   
     i f   ( o r i g i n a l )   
         m e s s a g e   + =   '   '   +   o r i g i n a l ;   
     v a r   e   =   n e w   E r r o r ( m e s s a g e ) ;   
     e . c o d e   =   e r r n a m e ;   
     e . e r r n o   =   e r r n a m e ;   
     e . s y s c a l l   =   s y s c a l l ;   
     r e t u r n   e ;   
 } ;   
   
   
 e x p o r t s . _ e x c e p t i o n W i t h H o s t P o r t   =   f u n c t i o n ( e r r ,   
                                                                                     s y s c a l l ,   
                                                                                     a d d r e s s ,   
                                                                                     p o r t ,   
                                                                                     a d d i t i o n a l )   {   
     v a r   d e t a i l s ;   
     i f   ( p o r t   & &   p o r t   >   0 )   {   
         d e t a i l s   =   a d d r e s s   +   ' : '   +   p o r t ;   
     }   e l s e   {   
         d e t a i l s   =   a d d r e s s ;   
     }   
   
     i f   ( a d d i t i o n a l )   {   
         d e t a i l s   + =   '   -   L o c a l   ( '   +   a d d i t i o n a l   +   ' ) ' ;   
     }   
     v a r   e x   =   e x p o r t s . _ e r r n o E x c e p t i o n ( e r r ,   s y s c a l l ,   d e t a i l s ) ;   
     e x . a d d r e s s   =   a d d r e s s ;   
     i f   ( p o r t )   {   
         e x . p o r t   =   p o r t ;   
     }   
     r e t u r n   e x ;   
 } ;   
 
 } ) ;   �  D   ��
 N O D E _ M O D U L E S / V M . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / * *     
   *   F a k e   v m   
   *   @ m o d u l e   v m   
   *   @ m e m b e r O f   m o d u l e : b u i l d i n   
   * /   
   
 c o n s t   { r u n I n T h i s C o n t e x t ,   l o a d D l l }   =   p r o c e s s . b i n d i n g ( ' m o d u l e s ' ) ;   
 / * *     
   *   N o d e   e x p e c t   t h i s   c o n f i g   
 {   
         f i l e n a m e :   f i l e n a m e ,   
         l i n e O f f s e t :   0 ,   
         d i s p l a y E r r o r s :   t r u e   
     }   
   * /   
 e x p o r t s . r u n I n T h i s C o n t e x t   =   f u n c t i o n ( c o d e ,   c o n f i g ) {   
     r e t u r n   r u n I n T h i s C o n t e x t ( c o d e ,   c o n f i g . f i l e n a m e )   
 }   
 e x p o r t s . r u n I n D e b u g C o n t e x t   =   f u n c t i o n ( ) { } ; 
 } ) ;   �   H   ��
 N O D E _ M O D U L E S / Z L I B . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {     / /   f a k e   z l i b   
 } ) ; ,  \   ��
 N O D E _ M O D U L E S / _ S T R E A M _ D U P L E X . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / /   a   d u p l e x   s t r e a m   i s   j u s t   a   s t r e a m   t h a t   i s   b o t h   r e a d a b l e   a n d   w r i t a b l e .   
 / /   S i n c e   J S   d o e s n ' t   h a v e   m u l t i p l e   p r o t o t y p a l   i n h e r i t a n c e ,   t h i s   c l a s s   
 / /   p r o t o t y p a l l y   i n h e r i t s   f r o m   R e a d a b l e ,   a n d   t h e n   p a r a s i t i c a l l y   f r o m   
 / /   W r i t a b l e .   
   
 ' u s e   s t r i c t ' ;   
   
 m o d u l e . e x p o r t s   =   D u p l e x ;   
   
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
 c o n s t   R e a d a b l e   =   r e q u i r e ( ' _ s t r e a m _ r e a d a b l e ' ) ;   
 c o n s t   W r i t a b l e   =   r e q u i r e ( ' _ s t r e a m _ w r i t a b l e ' ) ;   
   
 u t i l . i n h e r i t s ( D u p l e x ,   R e a d a b l e ) ;   
   
 v a r   k e y s   =   O b j e c t . k e y s ( W r i t a b l e . p r o t o t y p e ) ;   
 f o r   ( v a r   v   =   0 ;   v   <   k e y s . l e n g t h ;   v + + )   {   
     v a r   m e t h o d   =   k e y s [ v ] ;   
     i f   ( ! D u p l e x . p r o t o t y p e [ m e t h o d ] )   
         D u p l e x . p r o t o t y p e [ m e t h o d ]   =   W r i t a b l e . p r o t o t y p e [ m e t h o d ] ;   
 }   
   
 f u n c t i o n   D u p l e x ( o p t i o n s )   {   
     i f   ( ! ( t h i s   i n s t a n c e o f   D u p l e x ) )   
         r e t u r n   n e w   D u p l e x ( o p t i o n s ) ;   
   
     R e a d a b l e . c a l l ( t h i s ,   o p t i o n s ) ;   
     W r i t a b l e . c a l l ( t h i s ,   o p t i o n s ) ;   
   
     i f   ( o p t i o n s   & &   o p t i o n s . r e a d a b l e   = = =   f a l s e )   
         t h i s . r e a d a b l e   =   f a l s e ;   
   
     i f   ( o p t i o n s   & &   o p t i o n s . w r i t a b l e   = = =   f a l s e )   
         t h i s . w r i t a b l e   =   f a l s e ;   
   
     t h i s . a l l o w H a l f O p e n   =   t r u e ;   
     i f   ( o p t i o n s   & &   o p t i o n s . a l l o w H a l f O p e n   = = =   f a l s e )   
         t h i s . a l l o w H a l f O p e n   =   f a l s e ;   
   
     t h i s . o n c e ( ' e n d ' ,   o n e n d ) ;   
 }   
   
 / /   t h e   n o - h a l f - o p e n   e n f o r c e r   
 f u n c t i o n   o n e n d ( )   {   
     / /   i f   w e   a l l o w   h a l f - o p e n   s t a t e ,   o r   i f   t h e   w r i t a b l e   s i d e   e n d e d ,   
     / /   t h e n   w e ' r e   o k .   
     i f   ( t h i s . a l l o w H a l f O p e n   | |   t h i s . _ w r i t a b l e S t a t e . e n d e d )   
         r e t u r n ;   
   
     / /   n o   m o r e   d a t a   c a n   b e   w r i t t e n .   
     / /   B u t   a l l o w   m o r e   w r i t e s   t o   h a p p e n   i n   t h i s   t i c k .   
     p r o c e s s . n e x t T i c k ( o n E n d N T ,   t h i s ) ;   
 }   
   
 f u n c t i o n   o n E n d N T ( s e l f )   {   
     s e l f . e n d ( ) ;   
 }   
 
 } ) ; �  d   ��
 N O D E _ M O D U L E S / _ S T R E A M _ P A S S T H R O U G H . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / /   a   p a s s t h r o u g h   s t r e a m .   
 / /   b a s i c a l l y   j u s t   t h e   m o s t   m i n i m a l   s o r t   o f   T r a n s f o r m   s t r e a m .   
 / /   E v e r y   w r i t t e n   c h u n k   g e t s   o u t p u t   a s - i s .   
   
 ' u s e   s t r i c t ' ;   
   
 m o d u l e . e x p o r t s   =   P a s s T h r o u g h ;   
   
 c o n s t   T r a n s f o r m   =   r e q u i r e ( ' _ s t r e a m _ t r a n s f o r m ' ) ;   
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
 u t i l . i n h e r i t s ( P a s s T h r o u g h ,   T r a n s f o r m ) ;   
   
 f u n c t i o n   P a s s T h r o u g h ( o p t i o n s )   {   
     i f   ( ! ( t h i s   i n s t a n c e o f   P a s s T h r o u g h ) )   
         r e t u r n   n e w   P a s s T h r o u g h ( o p t i o n s ) ;   
   
     T r a n s f o r m . c a l l ( t h i s ,   o p t i o n s ) ;   
 }   
   
 P a s s T h r o u g h . p r o t o t y p e . _ t r a n s f o r m   =   f u n c t i o n ( c h u n k ,   e n c o d i n g ,   c b )   {   
     c b ( n u l l ,   c h u n k ) ;   
 } ;   
 
 } ) ; |�  `   ��
 N O D E _ M O D U L E S / _ S T R E A M _ R E A D A B L E . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ' u s e   s t r i c t ' ;   
   
 m o d u l e . e x p o r t s   =   R e a d a b l e ;   
 R e a d a b l e . R e a d a b l e S t a t e   =   R e a d a b l e S t a t e ;   
   
 c o n s t   E E   =   r e q u i r e ( ' e v e n t s ' ) ;   
 c o n s t   S t r e a m   =   r e q u i r e ( ' s t r e a m ' ) ;   
 c o n s t   B u f f e r   =   r e q u i r e ( ' b u f f e r ' ) . B u f f e r ;   
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
 c o n s t   d e b u g   =   u t i l . d e b u g l o g ( ' s t r e a m ' ) ;   
 c o n s t   B u f f e r L i s t   =   r e q u i r e ( ' i n t e r n a l / s t r e a m s / B u f f e r L i s t ' ) ;   
 v a r   S t r i n g D e c o d e r ;   
   
 u t i l . i n h e r i t s ( R e a d a b l e ,   S t r e a m ) ;   
   
 f u n c t i o n   p r e p e n d L i s t e n e r ( e m i t t e r ,   e v e n t ,   f n )   {   
     / /   S a d l y   t h i s   i s   n o t   c a c h e a b l e   a s   s o m e   l i b r a r i e s   b u n d l e   t h e i r   o w n   
     / /   e v e n t   e m i t t e r   i m p l e m e n t a t i o n   w i t h   t h e m .   
     i f   ( t y p e o f   e m i t t e r . p r e p e n d L i s t e n e r   = = =   ' f u n c t i o n ' )   {   
         r e t u r n   e m i t t e r . p r e p e n d L i s t e n e r ( e v e n t ,   f n ) ;   
     }   e l s e   {   
         / /   T h i s   i s   a   h a c k   t o   m a k e   s u r e   t h a t   o u r   e r r o r   h a n d l e r   i s   a t t a c h e d   b e f o r e   a n y   
         / /   u s e r l a n d   o n e s .     N E V E R   D O   T H I S .   T h i s   i s   h e r e   o n l y   b e c a u s e   t h i s   c o d e   n e e d s   
         / /   t o   c o n t i n u e   t o   w o r k   w i t h   o l d e r   v e r s i o n s   o f   N o d e . j s   t h a t   d o   n o t   i n c l u d e   
         / /   t h e   p r e p e n d L i s t e n e r ( )   m e t h o d .   T h e   g o a l   i s   t o   e v e n t u a l l y   r e m o v e   t h i s   h a c k .   
         i f   ( ! e m i t t e r . _ e v e n t s   | |   ! e m i t t e r . _ e v e n t s [ e v e n t ] )   
             e m i t t e r . o n ( e v e n t ,   f n ) ;   
         e l s e   i f   ( A r r a y . i s A r r a y ( e m i t t e r . _ e v e n t s [ e v e n t ] ) )   
             e m i t t e r . _ e v e n t s [ e v e n t ] . u n s h i f t ( f n ) ;   
         e l s e   
             e m i t t e r . _ e v e n t s [ e v e n t ]   =   [ f n ,   e m i t t e r . _ e v e n t s [ e v e n t ] ] ;   
     }   
 }   
   
 f u n c t i o n   R e a d a b l e S t a t e ( o p t i o n s ,   s t r e a m )   {   
     o p t i o n s   =   o p t i o n s   | |   { } ;   
   
     / /   o b j e c t   s t r e a m   f l a g .   U s e d   t o   m a k e   r e a d ( n )   i g n o r e   n   a n d   t o   
     / /   m a k e   a l l   t h e   b u f f e r   m e r g i n g   a n d   l e n g t h   c h e c k s   g o   a w a y   
     t h i s . o b j e c t M o d e   =   ! ! o p t i o n s . o b j e c t M o d e ;   
   
     i f   ( s t r e a m   i n s t a n c e o f   S t r e a m . D u p l e x )   
         t h i s . o b j e c t M o d e   =   t h i s . o b j e c t M o d e   | |   ! ! o p t i o n s . r e a d a b l e O b j e c t M o d e ;   
   
     / /   t h e   p o i n t   a t   w h i c h   i t   s t o p s   c a l l i n g   _ r e a d ( )   t o   f i l l   t h e   b u f f e r   
     / /   N o t e :   0   i s   a   v a l i d   v a l u e ,   m e a n s   " d o n ' t   c a l l   _ r e a d   p r e e m p t i v e l y   e v e r "   
     v a r   h w m   =   o p t i o n s . h i g h W a t e r M a r k ;   
     v a r   d e f a u l t H w m   =   t h i s . o b j e c t M o d e   ?   1 6   :   1 6   *   1 0 2 4 ;   
     t h i s . h i g h W a t e r M a r k   =   ( h w m   | |   h w m   = = =   0 )   ?   h w m   :   d e f a u l t H w m ;   
   
     / /   c a s t   t o   i n t s .   
     t h i s . h i g h W a t e r M a r k   =   ~ ~ t h i s . h i g h W a t e r M a r k ;   
   
     / /   A   l i n k e d   l i s t   i s   u s e d   t o   s t o r e   d a t a   c h u n k s   i n s t e a d   o f   a n   a r r a y   b e c a u s e   t h e   
     / /   l i n k e d   l i s t   c a n   r e m o v e   e l e m e n t s   f r o m   t h e   b e g i n n i n g   f a s t e r   t h a n   
     / /   a r r a y . s h i f t ( )   
     t h i s . b u f f e r   =   n e w   B u f f e r L i s t ( ) ;   
     t h i s . l e n g t h   =   0 ;   
     t h i s . p i p e s   =   n u l l ;   
     t h i s . p i p e s C o u n t   =   0 ;   
     t h i s . f l o w i n g   =   n u l l ;   
     t h i s . e n d e d   =   f a l s e ;   
     t h i s . e n d E m i t t e d   =   f a l s e ;   
     t h i s . r e a d i n g   =   f a l s e ;   
   
     / /   a   f l a g   t o   b e   a b l e   t o   t e l l   i f   t h e   o n w r i t e   c b   i s   c a l l e d   i m m e d i a t e l y ,   
     / /   o r   o n   a   l a t e r   t i c k .     W e   s e t   t h i s   t o   t r u e   a t   f i r s t ,   b e c a u s e   a n y   
     / /   a c t i o n s   t h a t   s h o u l d n ' t   h a p p e n   u n t i l   " l a t e r "   s h o u l d   g e n e r a l l y   a l s o   
     / /   n o t   h a p p e n   b e f o r e   t h e   f i r s t   w r i t e   c a l l .   
     t h i s . s y n c   =   t r u e ;   
   
     / /   w h e n e v e r   w e   r e t u r n   n u l l ,   t h e n   w e   s e t   a   f l a g   t o   s a y   
     / /   t h a t   w e ' r e   a w a i t i n g   a   ' r e a d a b l e '   e v e n t   e m i s s i o n .   
     t h i s . n e e d R e a d a b l e   =   f a l s e ;   
     t h i s . e m i t t e d R e a d a b l e   =   f a l s e ;   
     t h i s . r e a d a b l e L i s t e n i n g   =   f a l s e ;   
     t h i s . r e s u m e S c h e d u l e d   =   f a l s e ;   
   
     / /   C r y p t o   i s   k i n d   o f   o l d   a n d   c r u s t y .     H i s t o r i c a l l y ,   i t s   d e f a u l t   s t r i n g   
     / /   e n c o d i n g   i s   ' b i n a r y '   s o   w e   h a v e   t o   m a k e   t h i s   c o n f i g u r a b l e .   
     / /   E v e r y t h i n g   e l s e   i n   t h e   u n i v e r s e   u s e s   ' u t f 8 ' ,   t h o u g h .   
     t h i s . d e f a u l t E n c o d i n g   =   o p t i o n s . d e f a u l t E n c o d i n g   | |   ' u t f 8 ' ;   
   
     / /   w h e n   p i p i n g ,   w e   o n l y   c a r e   a b o u t   ' r e a d a b l e '   e v e n t s   t h a t   h a p p e n   
     / /   a f t e r   r e a d ( ) i n g   a l l   t h e   b y t e s   a n d   n o t   g e t t i n g   a n y   p u s h b a c k .   
     t h i s . r a n O u t   =   f a l s e ;   
   
     / /   t h e   n u m b e r   o f   w r i t e r s   t h a t   a r e   a w a i t i n g   a   d r a i n   e v e n t   i n   . p i p e ( ) s   
     t h i s . a w a i t D r a i n   =   0 ;   
   
     / /   i f   t r u e ,   a   m a y b e R e a d M o r e   h a s   b e e n   s c h e d u l e d   
     t h i s . r e a d i n g M o r e   =   f a l s e ;   
   
     t h i s . d e c o d e r   =   n u l l ;   
     t h i s . e n c o d i n g   =   n u l l ;   
     i f   ( o p t i o n s . e n c o d i n g )   {   
         i f   ( ! S t r i n g D e c o d e r )   
             S t r i n g D e c o d e r   =   r e q u i r e ( ' s t r i n g _ d e c o d e r ' ) . S t r i n g D e c o d e r ;   
         t h i s . d e c o d e r   =   n e w   S t r i n g D e c o d e r ( o p t i o n s . e n c o d i n g ) ;   
         t h i s . e n c o d i n g   =   o p t i o n s . e n c o d i n g ;   
     }   
 }   
   
 f u n c t i o n   R e a d a b l e ( o p t i o n s )   {   
     i f   ( ! ( t h i s   i n s t a n c e o f   R e a d a b l e ) )   
         r e t u r n   n e w   R e a d a b l e ( o p t i o n s ) ;   
   
     t h i s . _ r e a d a b l e S t a t e   =   n e w   R e a d a b l e S t a t e ( o p t i o n s ,   t h i s ) ;   
   
     / /   l e g a c y   
     t h i s . r e a d a b l e   =   t r u e ;   
   
     i f   ( o p t i o n s   & &   t y p e o f   o p t i o n s . r e a d   = = =   ' f u n c t i o n ' )   
         t h i s . _ r e a d   =   o p t i o n s . r e a d ;   
   
     S t r e a m . c a l l ( t h i s ) ;   
 }   
   
 / /   M a n u a l l y   s h o v e   s o m e t h i n g   i n t o   t h e   r e a d ( )   b u f f e r .   
 / /   T h i s   r e t u r n s   t r u e   i f   t h e   h i g h W a t e r M a r k   h a s   n o t   b e e n   h i t   y e t ,   
 / /   s i m i l a r   t o   h o w   W r i t a b l e . w r i t e ( )   r e t u r n s   t r u e   i f   y o u   s h o u l d   
 / /   w r i t e ( )   s o m e   m o r e .   
 R e a d a b l e . p r o t o t y p e . p u s h   =   f u n c t i o n ( c h u n k ,   e n c o d i n g )   {   
     v a r   s t a t e   =   t h i s . _ r e a d a b l e S t a t e ;   
   
     i f   ( ! s t a t e . o b j e c t M o d e   & &   t y p e o f   c h u n k   = = =   ' s t r i n g ' )   {   
         e n c o d i n g   =   e n c o d i n g   | |   s t a t e . d e f a u l t E n c o d i n g ;   
         i f   ( e n c o d i n g   ! = =   s t a t e . e n c o d i n g )   {   
             c h u n k   =   B u f f e r . f r o m ( c h u n k ,   e n c o d i n g ) ;   
             e n c o d i n g   =   ' ' ;   
         }   
     }   
   
     r e t u r n   r e a d a b l e A d d C h u n k ( t h i s ,   s t a t e ,   c h u n k ,   e n c o d i n g ,   f a l s e ) ;   
 } ;   
   
 / /   U n s h i f t   s h o u l d   * a l w a y s *   b e   s o m e t h i n g   d i r e c t l y   o u t   o f   r e a d ( )   
 R e a d a b l e . p r o t o t y p e . u n s h i f t   =   f u n c t i o n ( c h u n k )   {   
     v a r   s t a t e   =   t h i s . _ r e a d a b l e S t a t e ;   
     r e t u r n   r e a d a b l e A d d C h u n k ( t h i s ,   s t a t e ,   c h u n k ,   ' ' ,   t r u e ) ;   
 } ;   
   
 R e a d a b l e . p r o t o t y p e . i s P a u s e d   =   f u n c t i o n ( )   {   
     r e t u r n   t h i s . _ r e a d a b l e S t a t e . f l o w i n g   = = =   f a l s e ;   
 } ;   
   
 f u n c t i o n   r e a d a b l e A d d C h u n k ( s t r e a m ,   s t a t e ,   c h u n k ,   e n c o d i n g ,   a d d T o F r o n t )   {   
     v a r   e r   =   c h u n k I n v a l i d ( s t a t e ,   c h u n k ) ;   
     i f   ( e r )   {   
         s t r e a m . e m i t ( ' e r r o r ' ,   e r ) ;   
     }   e l s e   i f   ( c h u n k   = = =   n u l l )   {   
         s t a t e . r e a d i n g   =   f a l s e ;   
         o n E o f C h u n k ( s t r e a m ,   s t a t e ) ;   
     }   e l s e   i f   ( s t a t e . o b j e c t M o d e   | |   c h u n k   & &   c h u n k . l e n g t h   >   0 )   {   
         i f   ( s t a t e . e n d e d   & &   ! a d d T o F r o n t )   {   
             c o n s t   e   =   n e w   E r r o r ( ' s t r e a m . p u s h ( )   a f t e r   E O F ' ) ;   
             s t r e a m . e m i t ( ' e r r o r ' ,   e ) ;   
         }   e l s e   i f   ( s t a t e . e n d E m i t t e d   & &   a d d T o F r o n t )   {   
             c o n s t   e   =   n e w   E r r o r ( ' s t r e a m . u n s h i f t ( )   a f t e r   e n d   e v e n t ' ) ;   
             s t r e a m . e m i t ( ' e r r o r ' ,   e ) ;   
         }   e l s e   {   
             v a r   s k i p A d d ;   
             i f   ( s t a t e . d e c o d e r   & &   ! a d d T o F r o n t   & &   ! e n c o d i n g )   {   
                 c h u n k   =   s t a t e . d e c o d e r . w r i t e ( c h u n k ) ;   
                 s k i p A d d   =   ( ! s t a t e . o b j e c t M o d e   & &   c h u n k . l e n g t h   = = =   0 ) ;   
             }   
   
             i f   ( ! a d d T o F r o n t )   
                 s t a t e . r e a d i n g   =   f a l s e ;   
   
             / /   D o n ' t   a d d   t o   t h e   b u f f e r   i f   w e ' v e   d e c o d e d   t o   a n   e m p t y   s t r i n g   c h u n k   a n d   
             / /   w e ' r e   n o t   i n   o b j e c t   m o d e   
             i f   ( ! s k i p A d d )   {   
                 / /   i f   w e   w a n t   t h e   d a t a   n o w ,   j u s t   e m i t   i t .   
                 i f   ( s t a t e . f l o w i n g   & &   s t a t e . l e n g t h   = = =   0   & &   ! s t a t e . s y n c )   {   
                     s t r e a m . e m i t ( ' d a t a ' ,   c h u n k ) ;   
                     s t r e a m . r e a d ( 0 ) ;   
                 }   e l s e   {   
                     / /   u p d a t e   t h e   b u f f e r   i n f o .   
                     s t a t e . l e n g t h   + =   s t a t e . o b j e c t M o d e   ?   1   :   c h u n k . l e n g t h ;   
                     i f   ( a d d T o F r o n t )   
                         s t a t e . b u f f e r . u n s h i f t ( c h u n k ) ;   
                     e l s e   
                         s t a t e . b u f f e r . p u s h ( c h u n k ) ;   
   
                     i f   ( s t a t e . n e e d R e a d a b l e )   
                         e m i t R e a d a b l e ( s t r e a m ) ;   
                 }   
             }   
   
             m a y b e R e a d M o r e ( s t r e a m ,   s t a t e ) ;   
         }   
     }   e l s e   i f   ( ! a d d T o F r o n t )   {   
         s t a t e . r e a d i n g   =   f a l s e ;   
     }   
   
     r e t u r n   n e e d M o r e D a t a ( s t a t e ) ;   
 }   
   
   
 / /   i f   i t ' s   p a s t   t h e   h i g h   w a t e r   m a r k ,   w e   c a n   p u s h   i n   s o m e   m o r e .   
 / /   A l s o ,   i f   w e   h a v e   n o   d a t a   y e t ,   w e   c a n   s t a n d   s o m e   
 / /   m o r e   b y t e s .     T h i s   i s   t o   w o r k   a r o u n d   c a s e s   w h e r e   h w m = 0 ,   
 / /   s u c h   a s   t h e   r e p l .     A l s o ,   i f   t h e   p u s h ( )   t r i g g e r e d   a   
 / /   r e a d a b l e   e v e n t ,   a n d   t h e   u s e r   c a l l e d   r e a d ( l a r g e N u m b e r )   s u c h   t h a t   
 / /   n e e d R e a d a b l e   w a s   s e t ,   t h e n   w e   o u g h t   t o   p u s h   m o r e ,   s o   t h a t   a n o t h e r   
 / /   ' r e a d a b l e '   e v e n t   w i l l   b e   t r i g g e r e d .   
 f u n c t i o n   n e e d M o r e D a t a ( s t a t e )   {   
     r e t u r n   ! s t a t e . e n d e d   & &   
                   ( s t a t e . n e e d R e a d a b l e   | |   
                     s t a t e . l e n g t h   <   s t a t e . h i g h W a t e r M a r k   | |   
                     s t a t e . l e n g t h   = = =   0 ) ;   
 }   
   
 / /   b a c k w a r d s   c o m p a t i b i l i t y .   
 R e a d a b l e . p r o t o t y p e . s e t E n c o d i n g   =   f u n c t i o n ( e n c )   {   
     i f   ( ! S t r i n g D e c o d e r )   
         S t r i n g D e c o d e r   =   r e q u i r e ( ' s t r i n g _ d e c o d e r ' ) . S t r i n g D e c o d e r ;   
     t h i s . _ r e a d a b l e S t a t e . d e c o d e r   =   n e w   S t r i n g D e c o d e r ( e n c ) ;   
     t h i s . _ r e a d a b l e S t a t e . e n c o d i n g   =   e n c ;   
     r e t u r n   t h i s ;   
 } ;   
   
 / /   D o n ' t   r a i s e   t h e   h w m   >   8 M B   
 c o n s t   M A X _ H W M   =   0 x 8 0 0 0 0 0 ;   
 f u n c t i o n   c o m p u t e N e w H i g h W a t e r M a r k ( n )   {   
     i f   ( n   > =   M A X _ H W M )   {   
         n   =   M A X _ H W M ;   
     }   e l s e   {   
         / /   G e t   t h e   n e x t   h i g h e s t   p o w e r   o f   2   t o   p r e v e n t   i n c r e a s i n g   h w m   e x c e s s i v e l y   i n   
         / /   t i n y   a m o u n t s   
         n - - ;   
         n   | =   n   > > >   1 ;   
         n   | =   n   > > >   2 ;   
         n   | =   n   > > >   4 ;   
         n   | =   n   > > >   8 ;   
         n   | =   n   > > >   1 6 ;   
         n + + ;   
     }   
     r e t u r n   n ;   
 }   
   
 / /   T h i s   f u n c t i o n   i s   d e s i g n e d   t o   b e   i n l i n a b l e ,   s o   p l e a s e   t a k e   c a r e   w h e n   m a k i n g   
 / /   c h a n g e s   t o   t h e   f u n c t i o n   b o d y .   
 f u n c t i o n   h o w M u c h T o R e a d ( n ,   s t a t e )   {   
     i f   ( n   < =   0   | |   ( s t a t e . l e n g t h   = = =   0   & &   s t a t e . e n d e d ) )   
         r e t u r n   0 ;   
     i f   ( s t a t e . o b j e c t M o d e )   
         r e t u r n   1 ;   
     i f   ( n   ! = =   n )   {   
         / /   O n l y   f l o w   o n e   b u f f e r   a t   a   t i m e   
         i f   ( s t a t e . f l o w i n g   & &   s t a t e . l e n g t h )   
             r e t u r n   s t a t e . b u f f e r . h e a d . d a t a . l e n g t h ;   
         e l s e   
             r e t u r n   s t a t e . l e n g t h ;   
     }   
     / /   I f   w e ' r e   a s k i n g   f o r   m o r e   t h a n   t h e   c u r r e n t   h w m ,   t h e n   r a i s e   t h e   h w m .   
     i f   ( n   >   s t a t e . h i g h W a t e r M a r k )   
         s t a t e . h i g h W a t e r M a r k   =   c o m p u t e N e w H i g h W a t e r M a r k ( n ) ;   
     i f   ( n   < =   s t a t e . l e n g t h )   
         r e t u r n   n ;   
     / /   D o n ' t   h a v e   e n o u g h   
     i f   ( ! s t a t e . e n d e d )   {   
         s t a t e . n e e d R e a d a b l e   =   t r u e ;   
         r e t u r n   0 ;   
     }   
     r e t u r n   s t a t e . l e n g t h ;   
 }   
   
 / /   y o u   c a n   o v e r r i d e   e i t h e r   t h i s   m e t h o d ,   o r   t h e   a s y n c   _ r e a d ( n )   b e l o w .   
 R e a d a b l e . p r o t o t y p e . r e a d   =   f u n c t i o n ( n )   {   
     d e b u g ( ' r e a d ' ,   n ) ;   
     n   =   p a r s e I n t ( n ,   1 0 ) ;   
     v a r   s t a t e   =   t h i s . _ r e a d a b l e S t a t e ;   
     v a r   n O r i g   =   n ;   
   
     i f   ( n   ! = =   0 )   
         s t a t e . e m i t t e d R e a d a b l e   =   f a l s e ;   
   
     / /   i f   w e ' r e   d o i n g   r e a d ( 0 )   t o   t r i g g e r   a   r e a d a b l e   e v e n t ,   b u t   w e   
     / /   a l r e a d y   h a v e   a   b u n c h   o f   d a t a   i n   t h e   b u f f e r ,   t h e n   j u s t   t r i g g e r   
     / /   t h e   ' r e a d a b l e '   e v e n t   a n d   m o v e   o n .   
     i f   ( n   = = =   0   & &   
             s t a t e . n e e d R e a d a b l e   & &   
             ( s t a t e . l e n g t h   > =   s t a t e . h i g h W a t e r M a r k   | |   s t a t e . e n d e d ) )   {   
         d e b u g ( ' r e a d :   e m i t R e a d a b l e ' ,   s t a t e . l e n g t h ,   s t a t e . e n d e d ) ;   
         i f   ( s t a t e . l e n g t h   = = =   0   & &   s t a t e . e n d e d )   
             e n d R e a d a b l e ( t h i s ) ;   
         e l s e   
             e m i t R e a d a b l e ( t h i s ) ;   
         r e t u r n   n u l l ;   
     }   
   
     n   =   h o w M u c h T o R e a d ( n ,   s t a t e ) ;   
   
     / /   i f   w e ' v e   e n d e d ,   a n d   w e ' r e   n o w   c l e a r ,   t h e n   f i n i s h   i t   u p .   
     i f   ( n   = = =   0   & &   s t a t e . e n d e d )   {   
         i f   ( s t a t e . l e n g t h   = = =   0 )   
             e n d R e a d a b l e ( t h i s ) ;   
         r e t u r n   n u l l ;   
     }   
   
     / /   A l l   t h e   a c t u a l   c h u n k   g e n e r a t i o n   l o g i c   n e e d s   t o   b e   
     / /   * b e l o w *   t h e   c a l l   t o   _ r e a d .     T h e   r e a s o n   i s   t h a t   i n   c e r t a i n   
     / /   s y n t h e t i c   s t r e a m   c a s e s ,   s u c h   a s   p a s s t h r o u g h   s t r e a m s ,   _ r e a d   
     / /   m a y   b e   a   c o m p l e t e l y   s y n c h r o n o u s   o p e r a t i o n   w h i c h   m a y   c h a n g e   
     / /   t h e   s t a t e   o f   t h e   r e a d   b u f f e r ,   p r o v i d i n g   e n o u g h   d a t a   w h e n   
     / /   b e f o r e   t h e r e   w a s   * n o t *   e n o u g h .   
     / /   
     / /   S o ,   t h e   s t e p s   a r e :   
     / /   1 .   F i g u r e   o u t   w h a t   t h e   s t a t e   o f   t h i n g s   w i l l   b e   a f t e r   w e   d o   
     / /   a   r e a d   f r o m   t h e   b u f f e r .   
     / /   
     / /   2 .   I f   t h a t   r e s u l t i n g   s t a t e   w i l l   t r i g g e r   a   _ r e a d ,   t h e n   c a l l   _ r e a d .   
     / /   N o t e   t h a t   t h i s   m a y   b e   a s y n c h r o n o u s ,   o r   s y n c h r o n o u s .     Y e s ,   i t   i s   
     / /   d e e p l y   u g l y   t o   w r i t e   A P I s   t h i s   w a y ,   b u t   t h a t   s t i l l   d o e s n ' t   m e a n   
     / /   t h a t   t h e   R e a d a b l e   c l a s s   s h o u l d   b e h a v e   i m p r o p e r l y ,   a s   s t r e a m s   a r e   
     / /   d e s i g n e d   t o   b e   s y n c / a s y n c   a g n o s t i c .   
     / /   T a k e   n o t e   i f   t h e   _ r e a d   c a l l   i s   s y n c   o r   a s y n c   ( i e ,   i f   t h e   r e a d   c a l l   
     / /   h a s   r e t u r n e d   y e t ) ,   s o   t h a t   w e   k n o w   w h e t h e r   o r   n o t   i t ' s   s a f e   t o   e m i t   
     / /   ' r e a d a b l e '   e t c .   
     / /   
     / /   3 .   A c t u a l l y   p u l l   t h e   r e q u e s t e d   c h u n k s   o u t   o f   t h e   b u f f e r   a n d   r e t u r n .   
   
     / /   i f   w e   n e e d   a   r e a d a b l e   e v e n t ,   t h e n   w e   n e e d   t o   d o   s o m e   r e a d i n g .   
     v a r   d o R e a d   =   s t a t e . n e e d R e a d a b l e ;   
     d e b u g ( ' n e e d   r e a d a b l e ' ,   d o R e a d ) ;   
   
     / /   i f   w e   c u r r e n t l y   h a v e   l e s s   t h a n   t h e   h i g h W a t e r M a r k ,   t h e n   a l s o   r e a d   s o m e   
     i f   ( s t a t e . l e n g t h   = = =   0   | |   s t a t e . l e n g t h   -   n   <   s t a t e . h i g h W a t e r M a r k )   {   
         d o R e a d   =   t r u e ;   
         d e b u g ( ' l e n g t h   l e s s   t h a n   w a t e r m a r k ' ,   d o R e a d ) ;   
     }   
   
     / /   h o w e v e r ,   i f   w e ' v e   e n d e d ,   t h e n   t h e r e ' s   n o   p o i n t ,   a n d   i f   w e ' r e   a l r e a d y   
     / /   r e a d i n g ,   t h e n   i t ' s   u n n e c e s s a r y .   
     i f   ( s t a t e . e n d e d   | |   s t a t e . r e a d i n g )   {   
         d o R e a d   =   f a l s e ;   
         d e b u g ( ' r e a d i n g   o r   e n d e d ' ,   d o R e a d ) ;   
     }   e l s e   i f   ( d o R e a d )   {   
         d e b u g ( ' d o   r e a d ' ) ;   
         s t a t e . r e a d i n g   =   t r u e ;   
         s t a t e . s y n c   =   t r u e ;   
         / /   i f   t h e   l e n g t h   i s   c u r r e n t l y   z e r o ,   t h e n   w e   * n e e d *   a   r e a d a b l e   e v e n t .   
         i f   ( s t a t e . l e n g t h   = = =   0 )   
             s t a t e . n e e d R e a d a b l e   =   t r u e ;   
         / /   c a l l   i n t e r n a l   r e a d   m e t h o d   
         t h i s . _ r e a d ( s t a t e . h i g h W a t e r M a r k ) ;   
         s t a t e . s y n c   =   f a l s e ;   
         / /   I f   _ r e a d   p u s h e d   d a t a   s y n c h r o n o u s l y ,   t h e n   ` r e a d i n g `   w i l l   b e   f a l s e ,   
         / /   a n d   w e   n e e d   t o   r e - e v a l u a t e   h o w   m u c h   d a t a   w e   c a n   r e t u r n   t o   t h e   u s e r .   
         i f   ( ! s t a t e . r e a d i n g )   
             n   =   h o w M u c h T o R e a d ( n O r i g ,   s t a t e ) ;   
     }   
   
     v a r   r e t ;   
     i f   ( n   >   0 )   
         r e t   =   f r o m L i s t ( n ,   s t a t e ) ;   
     e l s e   
         r e t   =   n u l l ;   
   
     i f   ( r e t   = = =   n u l l )   {   
         s t a t e . n e e d R e a d a b l e   =   t r u e ;   
         n   =   0 ;   
     }   e l s e   {   
         s t a t e . l e n g t h   - =   n ;   
     }   
   
     i f   ( s t a t e . l e n g t h   = = =   0 )   {   
         / /   I f   w e   h a v e   n o t h i n g   i n   t h e   b u f f e r ,   t h e n   w e   w a n t   t o   k n o w   
         / /   a s   s o o n   a s   w e   * d o *   g e t   s o m e t h i n g   i n t o   t h e   b u f f e r .   
         i f   ( ! s t a t e . e n d e d )   
             s t a t e . n e e d R e a d a b l e   =   t r u e ;   
   
         / /   I f   w e   t r i e d   t o   r e a d ( )   p a s t   t h e   E O F ,   t h e n   e m i t   e n d   o n   t h e   n e x t   t i c k .   
         i f   ( n O r i g   ! = =   n   & &   s t a t e . e n d e d )   
             e n d R e a d a b l e ( t h i s ) ;   
     }   
   
     i f   ( r e t   ! = =   n u l l )   
         t h i s . e m i t ( ' d a t a ' ,   r e t ) ;   
   
     r e t u r n   r e t ;   
 } ;   
   
 f u n c t i o n   c h u n k I n v a l i d ( s t a t e ,   c h u n k )   {   
     v a r   e r   =   n u l l ;   
     i f   ( ! ( c h u n k   i n s t a n c e o f   B u f f e r )   & &   
             t y p e o f   c h u n k   ! = =   ' s t r i n g '   & &   
             c h u n k   ! = =   n u l l   & &   
             c h u n k   ! = =   u n d e f i n e d   & &   
             ! s t a t e . o b j e c t M o d e )   {   
         e r   =   n e w   T y p e E r r o r ( ' I n v a l i d   n o n - s t r i n g / b u f f e r   c h u n k ' ) ;   
     }   
     r e t u r n   e r ;   
 }   
   
   
 f u n c t i o n   o n E o f C h u n k ( s t r e a m ,   s t a t e )   {   
     i f   ( s t a t e . e n d e d )   r e t u r n ;   
     i f   ( s t a t e . d e c o d e r )   {   
         v a r   c h u n k   =   s t a t e . d e c o d e r . e n d ( ) ;   
         i f   ( c h u n k   & &   c h u n k . l e n g t h )   {   
             s t a t e . b u f f e r . p u s h ( c h u n k ) ;   
             s t a t e . l e n g t h   + =   s t a t e . o b j e c t M o d e   ?   1   :   c h u n k . l e n g t h ;   
         }   
     }   
     s t a t e . e n d e d   =   t r u e ;   
   
     / /   e m i t   ' r e a d a b l e '   n o w   t o   m a k e   s u r e   i t   g e t s   p i c k e d   u p .   
     e m i t R e a d a b l e ( s t r e a m ) ;   
 }   
   
 / /   D o n ' t   e m i t   r e a d a b l e   r i g h t   a w a y   i n   s y n c   m o d e ,   b e c a u s e   t h i s   c a n   t r i g g e r   
 / /   a n o t h e r   r e a d ( )   c a l l   = >   s t a c k   o v e r f l o w .     T h i s   w a y ,   i t   m i g h t   t r i g g e r   
 / /   a   n e x t T i c k   r e c u r s i o n   w a r n i n g ,   b u t   t h a t ' s   n o t   s o   b a d .   
 f u n c t i o n   e m i t R e a d a b l e ( s t r e a m )   {   
     v a r   s t a t e   =   s t r e a m . _ r e a d a b l e S t a t e ;   
     s t a t e . n e e d R e a d a b l e   =   f a l s e ;   
     i f   ( ! s t a t e . e m i t t e d R e a d a b l e )   {   
         d e b u g ( ' e m i t R e a d a b l e ' ,   s t a t e . f l o w i n g ) ;   
         s t a t e . e m i t t e d R e a d a b l e   =   t r u e ;   
         i f   ( s t a t e . s y n c )   
             p r o c e s s . n e x t T i c k ( e m i t R e a d a b l e _ ,   s t r e a m ) ;   
         e l s e   
             e m i t R e a d a b l e _ ( s t r e a m ) ;   
     }   
 }   
   
 f u n c t i o n   e m i t R e a d a b l e _ ( s t r e a m )   {   
     d e b u g ( ' e m i t   r e a d a b l e ' ) ;   
     s t r e a m . e m i t ( ' r e a d a b l e ' ) ;   
     f l o w ( s t r e a m ) ;   
 }   
   
   
 / /   a t   t h i s   p o i n t ,   t h e   u s e r   h a s   p r e s u m a b l y   s e e n   t h e   ' r e a d a b l e '   e v e n t ,   
 / /   a n d   c a l l e d   r e a d ( )   t o   c o n s u m e   s o m e   d a t a .     t h a t   m a y   h a v e   t r i g g e r e d   
 / /   i n   t u r n   a n o t h e r   _ r e a d ( n )   c a l l ,   i n   w h i c h   c a s e   r e a d i n g   =   t r u e   i f   
 / /   i t ' s   i n   p r o g r e s s .   
 / /   H o w e v e r ,   i f   w e ' r e   n o t   e n d e d ,   o r   r e a d i n g ,   a n d   t h e   l e n g t h   <   h w m ,   
 / /   t h e n   g o   a h e a d   a n d   t r y   t o   r e a d   s o m e   m o r e   p r e e m p t i v e l y .   
 f u n c t i o n   m a y b e R e a d M o r e ( s t r e a m ,   s t a t e )   {   
     i f   ( ! s t a t e . r e a d i n g M o r e )   {   
         s t a t e . r e a d i n g M o r e   =   t r u e ;   
         p r o c e s s . n e x t T i c k ( m a y b e R e a d M o r e _ ,   s t r e a m ,   s t a t e ) ;   
     }   
 }   
   
 f u n c t i o n   m a y b e R e a d M o r e _ ( s t r e a m ,   s t a t e )   {   
     v a r   l e n   =   s t a t e . l e n g t h ;   
     w h i l e   ( ! s t a t e . r e a d i n g   & &   ! s t a t e . f l o w i n g   & &   ! s t a t e . e n d e d   & &   
                   s t a t e . l e n g t h   <   s t a t e . h i g h W a t e r M a r k )   {   
         d e b u g ( ' m a y b e R e a d M o r e   r e a d   0 ' ) ;   
         s t r e a m . r e a d ( 0 ) ;   
         i f   ( l e n   = = =   s t a t e . l e n g t h )   
             / /   d i d n ' t   g e t   a n y   d a t a ,   s t o p   s p i n n i n g .   
             b r e a k ;   
         e l s e   
             l e n   =   s t a t e . l e n g t h ;   
     }   
     s t a t e . r e a d i n g M o r e   =   f a l s e ;   
 }   
   
 / /   a b s t r a c t   m e t h o d .     t o   b e   o v e r r i d d e n   i n   s p e c i f i c   i m p l e m e n t a t i o n   c l a s s e s .   
 / /   c a l l   c b ( e r ,   d a t a )   w h e r e   d a t a   i s   < =   n   i n   l e n g t h .   
 / /   f o r   v i r t u a l   ( n o n - s t r i n g ,   n o n - b u f f e r )   s t r e a m s ,   " l e n g t h "   i s   s o m e w h a t   
 / /   a r b i t r a r y ,   a n d   p e r h a p s   n o t   v e r y   m e a n i n g f u l .   
 R e a d a b l e . p r o t o t y p e . _ r e a d   =   f u n c t i o n ( n )   {   
     t h i s . e m i t ( ' e r r o r ' ,   n e w   E r r o r ( ' n o t   i m p l e m e n t e d ' ) ) ;   
 } ;   
   
 R e a d a b l e . p r o t o t y p e . p i p e   =   f u n c t i o n ( d e s t ,   p i p e O p t s )   {   
     v a r   s r c   =   t h i s ;   
     v a r   s t a t e   =   t h i s . _ r e a d a b l e S t a t e ;   
   
     s w i t c h   ( s t a t e . p i p e s C o u n t )   {   
         c a s e   0 :   
             s t a t e . p i p e s   =   d e s t ;   
             b r e a k ;   
         c a s e   1 :   
             s t a t e . p i p e s   =   [ s t a t e . p i p e s ,   d e s t ] ;   
             b r e a k ;   
         d e f a u l t :   
             s t a t e . p i p e s . p u s h ( d e s t ) ;   
             b r e a k ;   
     }   
     s t a t e . p i p e s C o u n t   + =   1 ;   
     d e b u g ( ' p i p e   c o u n t = % d   o p t s = % j ' ,   s t a t e . p i p e s C o u n t ,   p i p e O p t s ) ;   
   
     v a r   d o E n d   =   ( ! p i p e O p t s   | |   p i p e O p t s . e n d   ! = =   f a l s e )   & &   
                             d e s t   ! = =   p r o c e s s . s t d o u t   & &   
                             d e s t   ! = =   p r o c e s s . s t d e r r ;   
   
     v a r   e n d F n   =   d o E n d   ?   o n e n d   :   c l e a n u p ;   
     i f   ( s t a t e . e n d E m i t t e d )   
         p r o c e s s . n e x t T i c k ( e n d F n ) ;   
     e l s e   
         s r c . o n c e ( ' e n d ' ,   e n d F n ) ;   
   
     d e s t . o n ( ' u n p i p e ' ,   o n u n p i p e ) ;   
     f u n c t i o n   o n u n p i p e ( r e a d a b l e )   {   
         d e b u g ( ' o n u n p i p e ' ) ;   
         i f   ( r e a d a b l e   = = =   s r c )   {   
             c l e a n u p ( ) ;   
         }   
     }   
   
     f u n c t i o n   o n e n d ( )   {   
         d e b u g ( ' o n e n d ' ) ;   
         d e s t . e n d ( ) ;   
     }   
   
     / /   w h e n   t h e   d e s t   d r a i n s ,   i t   r e d u c e s   t h e   a w a i t D r a i n   c o u n t e r   
     / /   o n   t h e   s o u r c e .     T h i s   w o u l d   b e   m o r e   e l e g a n t   w i t h   a   . o n c e ( )   
     / /   h a n d l e r   i n   f l o w ( ) ,   b u t   a d d i n g   a n d   r e m o v i n g   r e p e a t e d l y   i s   
     / /   t o o   s l o w .   
     v a r   o n d r a i n   =   p i p e O n D r a i n ( s r c ) ;   
     d e s t . o n ( ' d r a i n ' ,   o n d r a i n ) ;   
   
     v a r   c l e a n e d U p   =   f a l s e ;   
     f u n c t i o n   c l e a n u p ( )   {   
         d e b u g ( ' c l e a n u p ' ) ;   
         / /   c l e a n u p   e v e n t   h a n d l e r s   o n c e   t h e   p i p e   i s   b r o k e n   
         d e s t . r e m o v e L i s t e n e r ( ' c l o s e ' ,   o n c l o s e ) ;   
         d e s t . r e m o v e L i s t e n e r ( ' f i n i s h ' ,   o n f i n i s h ) ;   
         d e s t . r e m o v e L i s t e n e r ( ' d r a i n ' ,   o n d r a i n ) ;   
         d e s t . r e m o v e L i s t e n e r ( ' e r r o r ' ,   o n e r r o r ) ;   
         d e s t . r e m o v e L i s t e n e r ( ' u n p i p e ' ,   o n u n p i p e ) ;   
         s r c . r e m o v e L i s t e n e r ( ' e n d ' ,   o n e n d ) ;   
         s r c . r e m o v e L i s t e n e r ( ' e n d ' ,   c l e a n u p ) ;   
         s r c . r e m o v e L i s t e n e r ( ' d a t a ' ,   o n d a t a ) ;   
   
         c l e a n e d U p   =   t r u e ;   
   
         / /   i f   t h e   r e a d e r   i s   w a i t i n g   f o r   a   d r a i n   e v e n t   f r o m   t h i s   
         / /   s p e c i f i c   w r i t e r ,   t h e n   i t   w o u l d   c a u s e   i t   t o   n e v e r   s t a r t   
         / /   f l o w i n g   a g a i n .   
         / /   S o ,   i f   t h i s   i s   a w a i t i n g   a   d r a i n ,   t h e n   w e   j u s t   c a l l   i t   n o w .   
         / /   I f   w e   d o n ' t   k n o w ,   t h e n   a s s u m e   t h a t   w e   a r e   w a i t i n g   f o r   o n e .   
         i f   ( s t a t e . a w a i t D r a i n   & &   
                 ( ! d e s t . _ w r i t a b l e S t a t e   | |   d e s t . _ w r i t a b l e S t a t e . n e e d D r a i n ) )   
             o n d r a i n ( ) ;   
     }   
   
     / /   I f   t h e   u s e r   p u s h e s   m o r e   d a t a   w h i l e   w e ' r e   w r i t i n g   t o   d e s t   t h e n   w e ' l l   e n d   u p   
     / /   i n   o n d a t a   a g a i n .   H o w e v e r ,   w e   o n l y   w a n t   t o   i n c r e a s e   a w a i t D r a i n   o n c e   b e c a u s e   
     / /   d e s t   w i l l   o n l y   e m i t   o n e   ' d r a i n '   e v e n t   f o r   t h e   m u l t i p l e   w r i t e s .   
     / /   = >   I n t r o d u c e   a   g u a r d   o n   i n c r e a s i n g   a w a i t D r a i n .   
     v a r   i n c r e a s e d A w a i t D r a i n   =   f a l s e ;   
     s r c . o n ( ' d a t a ' ,   o n d a t a ) ;   
     f u n c t i o n   o n d a t a ( c h u n k )   {   
         d e b u g ( ' o n d a t a ' ) ;   
         i n c r e a s e d A w a i t D r a i n   =   f a l s e ;   
         v a r   r e t   =   d e s t . w r i t e ( c h u n k ) ;   
         i f   ( f a l s e   = = =   r e t   & &   ! i n c r e a s e d A w a i t D r a i n )   {   
             / /   I f   t h e   u s e r   u n p i p e d   d u r i n g   ` d e s t . w r i t e ( ) ` ,   i t   i s   p o s s i b l e   
             / /   t o   g e t   s t u c k   i n   a   p e r m a n e n t l y   p a u s e d   s t a t e   i f   t h a t   w r i t e   
             / /   a l s o   r e t u r n e d   f a l s e .   
             / /   = >   C h e c k   w h e t h e r   ` d e s t `   i s   s t i l l   a   p i p i n g   d e s t i n a t i o n .   
             i f   ( ( ( s t a t e . p i p e s C o u n t   = = =   1   & &   s t a t e . p i p e s   = = =   d e s t )   | |   
                       ( s t a t e . p i p e s C o u n t   >   1   & &   s t a t e . p i p e s . i n d e x O f ( d e s t )   ! = =   - 1 ) )   & &   
                     ! c l e a n e d U p )   {   
                 d e b u g ( ' f a l s e   w r i t e   r e s p o n s e ,   p a u s e ' ,   s r c . _ r e a d a b l e S t a t e . a w a i t D r a i n ) ;   
                 s r c . _ r e a d a b l e S t a t e . a w a i t D r a i n + + ;   
                 i n c r e a s e d A w a i t D r a i n   =   t r u e ;   
             }   
             s r c . p a u s e ( ) ;   
         }   
     }   
   
     / /   i f   t h e   d e s t   h a s   a n   e r r o r ,   t h e n   s t o p   p i p i n g   i n t o   i t .   
     / /   h o w e v e r ,   d o n ' t   s u p p r e s s   t h e   t h r o w i n g   b e h a v i o r   f o r   t h i s .   
     f u n c t i o n   o n e r r o r ( e r )   {   
         d e b u g ( ' o n e r r o r ' ,   e r ) ;   
         u n p i p e ( ) ;   
         d e s t . r e m o v e L i s t e n e r ( ' e r r o r ' ,   o n e r r o r ) ;   
         i f   ( E E . l i s t e n e r C o u n t ( d e s t ,   ' e r r o r ' )   = = =   0 )   
             d e s t . e m i t ( ' e r r o r ' ,   e r ) ;   
     }   
   
     / /   M a k e   s u r e   o u r   e r r o r   h a n d l e r   i s   a t t a c h e d   b e f o r e   u s e r l a n d   o n e s .   
     p r e p e n d L i s t e n e r ( d e s t ,   ' e r r o r ' ,   o n e r r o r ) ;   
   
     / /   B o t h   c l o s e   a n d   f i n i s h   s h o u l d   t r i g g e r   u n p i p e ,   b u t   o n l y   o n c e .   
     f u n c t i o n   o n c l o s e ( )   {   
         d e s t . r e m o v e L i s t e n e r ( ' f i n i s h ' ,   o n f i n i s h ) ;   
         u n p i p e ( ) ;   
     }   
     d e s t . o n c e ( ' c l o s e ' ,   o n c l o s e ) ;   
     f u n c t i o n   o n f i n i s h ( )   {   
         d e b u g ( ' o n f i n i s h ' ) ;   
         d e s t . r e m o v e L i s t e n e r ( ' c l o s e ' ,   o n c l o s e ) ;   
         u n p i p e ( ) ;   
     }   
     d e s t . o n c e ( ' f i n i s h ' ,   o n f i n i s h ) ;   
   
     f u n c t i o n   u n p i p e ( )   {   
         d e b u g ( ' u n p i p e ' ) ;   
         s r c . u n p i p e ( d e s t ) ;   
     }   
   
     / /   t e l l   t h e   d e s t   t h a t   i t ' s   b e i n g   p i p e d   t o   
     d e s t . e m i t ( ' p i p e ' ,   s r c ) ;   
   
     / /   s t a r t   t h e   f l o w   i f   i t   h a s n ' t   b e e n   s t a r t e d   a l r e a d y .   
     i f   ( ! s t a t e . f l o w i n g )   {   
         d e b u g ( ' p i p e   r e s u m e ' ) ;   
         s r c . r e s u m e ( ) ;   
     }   
   
     r e t u r n   d e s t ;   
 } ;   
   
 f u n c t i o n   p i p e O n D r a i n ( s r c )   {   
     r e t u r n   f u n c t i o n ( )   {   
         v a r   s t a t e   =   s r c . _ r e a d a b l e S t a t e ;   
         d e b u g ( ' p i p e O n D r a i n ' ,   s t a t e . a w a i t D r a i n ) ;   
         i f   ( s t a t e . a w a i t D r a i n )   
             s t a t e . a w a i t D r a i n - - ;   
         i f   ( s t a t e . a w a i t D r a i n   = = =   0   & &   E E . l i s t e n e r C o u n t ( s r c ,   ' d a t a ' ) )   {   
             s t a t e . f l o w i n g   =   t r u e ;   
             f l o w ( s r c ) ;   
         }   
     } ;   
 }   
   
   
 R e a d a b l e . p r o t o t y p e . u n p i p e   =   f u n c t i o n ( d e s t )   {   
     v a r   s t a t e   =   t h i s . _ r e a d a b l e S t a t e ;   
   
     / /   i f   w e ' r e   n o t   p i p i n g   a n y w h e r e ,   t h e n   d o   n o t h i n g .   
     i f   ( s t a t e . p i p e s C o u n t   = = =   0 )   
         r e t u r n   t h i s ;   
   
     / /   j u s t   o n e   d e s t i n a t i o n .     m o s t   c o m m o n   c a s e .   
     i f   ( s t a t e . p i p e s C o u n t   = = =   1 )   {   
         / /   p a s s e d   i n   o n e ,   b u t   i t ' s   n o t   t h e   r i g h t   o n e .   
         i f   ( d e s t   & &   d e s t   ! = =   s t a t e . p i p e s )   
             r e t u r n   t h i s ;   
   
         i f   ( ! d e s t )   
             d e s t   =   s t a t e . p i p e s ;   
   
         / /   g o t   a   m a t c h .   
         s t a t e . p i p e s   =   n u l l ;   
         s t a t e . p i p e s C o u n t   =   0 ;   
         s t a t e . f l o w i n g   =   f a l s e ;   
         i f   ( d e s t )   
             d e s t . e m i t ( ' u n p i p e ' ,   t h i s ) ;   
         r e t u r n   t h i s ;   
     }   
   
     / /   s l o w   c a s e .   m u l t i p l e   p i p e   d e s t i n a t i o n s .   
   
     i f   ( ! d e s t )   {   
         / /   r e m o v e   a l l .   
         v a r   d e s t s   =   s t a t e . p i p e s ;   
         v a r   l e n   =   s t a t e . p i p e s C o u n t ;   
         s t a t e . p i p e s   =   n u l l ;   
         s t a t e . p i p e s C o u n t   =   0 ;   
         s t a t e . f l o w i n g   =   f a l s e ;   
   
         f o r   ( l e t   i   =   0 ;   i   <   l e n ;   i + + )   
             d e s t s [ i ] . e m i t ( ' u n p i p e ' ,   t h i s ) ;   
         r e t u r n   t h i s ;   
     }   
   
     / /   t r y   t o   f i n d   t h e   r i g h t   o n e .   
     c o n s t   i   =   s t a t e . p i p e s . i n d e x O f ( d e s t ) ;   
     i f   ( i   = = =   - 1 )   
         r e t u r n   t h i s ;   
   
     s t a t e . p i p e s . s p l i c e ( i ,   1 ) ;   
     s t a t e . p i p e s C o u n t   - =   1 ;   
     i f   ( s t a t e . p i p e s C o u n t   = = =   1 )   
         s t a t e . p i p e s   =   s t a t e . p i p e s [ 0 ] ;   
   
     d e s t . e m i t ( ' u n p i p e ' ,   t h i s ) ;   
   
     r e t u r n   t h i s ;   
 } ;   
   
 / /   s e t   u p   d a t a   e v e n t s   i f   t h e y   a r e   a s k e d   f o r   
 / /   E n s u r e   r e a d a b l e   l i s t e n e r s   e v e n t u a l l y   g e t   s o m e t h i n g   
 R e a d a b l e . p r o t o t y p e . o n   =   f u n c t i o n ( e v ,   f n )   {   
     c o n s t   r e s   =   S t r e a m . p r o t o t y p e . o n . c a l l ( t h i s ,   e v ,   f n ) ;   
   
     i f   ( e v   = = =   ' d a t a ' )   {   
         / /   S t a r t   f l o w i n g   o n   n e x t   t i c k   i f   s t r e a m   i s n ' t   e x p l i c i t l y   p a u s e d   
         i f   ( t h i s . _ r e a d a b l e S t a t e . f l o w i n g   ! = =   f a l s e )   
             t h i s . r e s u m e ( ) ;   
     }   e l s e   i f   ( e v   = = =   ' r e a d a b l e ' )   {   
         c o n s t   s t a t e   =   t h i s . _ r e a d a b l e S t a t e ;   
         i f   ( ! s t a t e . e n d E m i t t e d   & &   ! s t a t e . r e a d a b l e L i s t e n i n g )   {   
             s t a t e . r e a d a b l e L i s t e n i n g   =   s t a t e . n e e d R e a d a b l e   =   t r u e ;   
             s t a t e . e m i t t e d R e a d a b l e   =   f a l s e ;   
             i f   ( ! s t a t e . r e a d i n g )   {   
                 p r o c e s s . n e x t T i c k ( n R e a d i n g N e x t T i c k ,   t h i s ) ;   
             }   e l s e   i f   ( s t a t e . l e n g t h )   {   
                 e m i t R e a d a b l e ( t h i s ,   s t a t e ) ;   
             }   
         }   
     }   
   
     r e t u r n   r e s ;   
 } ;   
 R e a d a b l e . p r o t o t y p e . a d d L i s t e n e r   =   R e a d a b l e . p r o t o t y p e . o n ;   
   
 f u n c t i o n   n R e a d i n g N e x t T i c k ( s e l f )   {   
     d e b u g ( ' r e a d a b l e   n e x t t i c k   r e a d   0 ' ) ;   
     s e l f . r e a d ( 0 ) ;   
 }   
   
 / /   p a u s e ( )   a n d   r e s u m e ( )   a r e   r e m n a n t s   o f   t h e   l e g a c y   r e a d a b l e   s t r e a m   A P I   
 / /   I f   t h e   u s e r   u s e s   t h e m ,   t h e n   s w i t c h   i n t o   o l d   m o d e .   
 R e a d a b l e . p r o t o t y p e . r e s u m e   =   f u n c t i o n ( )   {   
     v a r   s t a t e   =   t h i s . _ r e a d a b l e S t a t e ;   
     i f   ( ! s t a t e . f l o w i n g )   {   
         d e b u g ( ' r e s u m e ' ) ;   
         s t a t e . f l o w i n g   =   t r u e ;   
         r e s u m e ( t h i s ,   s t a t e ) ;   
     }   
     r e t u r n   t h i s ;   
 } ;   
   
 f u n c t i o n   r e s u m e ( s t r e a m ,   s t a t e )   {   
     i f   ( ! s t a t e . r e s u m e S c h e d u l e d )   {   
         s t a t e . r e s u m e S c h e d u l e d   =   t r u e ;   
         p r o c e s s . n e x t T i c k ( r e s u m e _ ,   s t r e a m ,   s t a t e ) ;   
     }   
 }   
   
 f u n c t i o n   r e s u m e _ ( s t r e a m ,   s t a t e )   {   
     i f   ( ! s t a t e . r e a d i n g )   {   
         d e b u g ( ' r e s u m e   r e a d   0 ' ) ;   
         s t r e a m . r e a d ( 0 ) ;   
     }   
   
     s t a t e . r e s u m e S c h e d u l e d   =   f a l s e ;   
     s t a t e . a w a i t D r a i n   =   0 ;   
     s t r e a m . e m i t ( ' r e s u m e ' ) ;   
     f l o w ( s t r e a m ) ;   
     i f   ( s t a t e . f l o w i n g   & &   ! s t a t e . r e a d i n g )   
         s t r e a m . r e a d ( 0 ) ;   
 }   
   
 R e a d a b l e . p r o t o t y p e . p a u s e   =   f u n c t i o n ( )   {   
     d e b u g ( ' c a l l   p a u s e   f l o w i n g = % j ' ,   t h i s . _ r e a d a b l e S t a t e . f l o w i n g ) ;   
     i f   ( f a l s e   ! = =   t h i s . _ r e a d a b l e S t a t e . f l o w i n g )   {   
         d e b u g ( ' p a u s e ' ) ;   
         t h i s . _ r e a d a b l e S t a t e . f l o w i n g   =   f a l s e ;   
         t h i s . e m i t ( ' p a u s e ' ) ;   
     }   
     r e t u r n   t h i s ;   
 } ;   
   
 f u n c t i o n   f l o w ( s t r e a m )   {   
     c o n s t   s t a t e   =   s t r e a m . _ r e a d a b l e S t a t e ;   
     d e b u g ( ' f l o w ' ,   s t a t e . f l o w i n g ) ;   
     w h i l e   ( s t a t e . f l o w i n g   & &   s t r e a m . r e a d ( )   ! = =   n u l l ) ;   
 }   
   
 / /   w r a p   a n   o l d - s t y l e   s t r e a m   a s   t h e   a s y n c   d a t a   s o u r c e .   
 / /   T h i s   i s   * n o t *   p a r t   o f   t h e   r e a d a b l e   s t r e a m   i n t e r f a c e .   
 / /   I t   i s   a n   u g l y   u n f o r t u n a t e   m e s s   o f   h i s t o r y .   
 R e a d a b l e . p r o t o t y p e . w r a p   =   f u n c t i o n ( s t r e a m )   {   
     v a r   s t a t e   =   t h i s . _ r e a d a b l e S t a t e ;   
     v a r   p a u s e d   =   f a l s e ;   
   
     v a r   s e l f   =   t h i s ;   
     s t r e a m . o n ( ' e n d ' ,   f u n c t i o n ( )   {   
         d e b u g ( ' w r a p p e d   e n d ' ) ;   
         i f   ( s t a t e . d e c o d e r   & &   ! s t a t e . e n d e d )   {   
             v a r   c h u n k   =   s t a t e . d e c o d e r . e n d ( ) ;   
             i f   ( c h u n k   & &   c h u n k . l e n g t h )   
                 s e l f . p u s h ( c h u n k ) ;   
         }   
   
         s e l f . p u s h ( n u l l ) ;   
     } ) ;   
   
     s t r e a m . o n ( ' d a t a ' ,   f u n c t i o n ( c h u n k )   {   
         d e b u g ( ' w r a p p e d   d a t a ' ) ;   
         i f   ( s t a t e . d e c o d e r )   
             c h u n k   =   s t a t e . d e c o d e r . w r i t e ( c h u n k ) ;   
   
         / /   d o n ' t   s k i p   o v e r   f a l s y   v a l u e s   i n   o b j e c t M o d e   
         i f   ( s t a t e . o b j e c t M o d e   & &   ( c h u n k   = = =   n u l l   | |   c h u n k   = = =   u n d e f i n e d ) )   
             r e t u r n ;   
         e l s e   i f   ( ! s t a t e . o b j e c t M o d e   & &   ( ! c h u n k   | |   ! c h u n k . l e n g t h ) )   
             r e t u r n ;   
   
         v a r   r e t   =   s e l f . p u s h ( c h u n k ) ;   
         i f   ( ! r e t )   {   
             p a u s e d   =   t r u e ;   
             s t r e a m . p a u s e ( ) ;   
         }   
     } ) ;   
   
     / /   p r o x y   a l l   t h e   o t h e r   m e t h o d s .   
     / /   i m p o r t a n t   w h e n   w r a p p i n g   f i l t e r s   a n d   d u p l e x e s .   
     f o r   ( v a r   i   i n   s t r e a m )   {   
         i f   ( t h i s [ i ]   = = =   u n d e f i n e d   & &   t y p e o f   s t r e a m [ i ]   = = =   ' f u n c t i o n ' )   {   
             t h i s [ i ]   =   f u n c t i o n ( m e t h o d )   {   
                 r e t u r n   f u n c t i o n ( )   {   
                     r e t u r n   s t r e a m [ m e t h o d ] . a p p l y ( s t r e a m ,   a r g u m e n t s ) ;   
                 } ;   
             } ( i ) ;   
         }   
     }   
   
     / /   p r o x y   c e r t a i n   i m p o r t a n t   e v e n t s .   
     c o n s t   e v e n t s   =   [ ' e r r o r ' ,   ' c l o s e ' ,   ' d e s t r o y ' ,   ' p a u s e ' ,   ' r e s u m e ' ] ;   
     e v e n t s . f o r E a c h ( f u n c t i o n ( e v )   {   
         s t r e a m . o n ( e v ,   s e l f . e m i t . b i n d ( s e l f ,   e v ) ) ;   
     } ) ;   
   
     / /   w h e n   w e   t r y   t o   c o n s u m e   s o m e   m o r e   b y t e s ,   s i m p l y   u n p a u s e   t h e   
     / /   u n d e r l y i n g   s t r e a m .   
     s e l f . _ r e a d   =   f u n c t i o n ( n )   {   
         d e b u g ( ' w r a p p e d   _ r e a d ' ,   n ) ;   
         i f   ( p a u s e d )   {   
             p a u s e d   =   f a l s e ;   
             s t r e a m . r e s u m e ( ) ;   
         }   
     } ;   
   
     r e t u r n   s e l f ;   
 } ;   
   
   
 / /   e x p o s e d   f o r   t e s t i n g   p u r p o s e s   o n l y .   
 R e a d a b l e . _ f r o m L i s t   =   f r o m L i s t ;   
   
 / /   P l u c k   o f f   n   b y t e s   f r o m   a n   a r r a y   o f   b u f f e r s .   
 / /   L e n g t h   i s   t h e   c o m b i n e d   l e n g t h s   o f   a l l   t h e   b u f f e r s   i n   t h e   l i s t .   
 / /   T h i s   f u n c t i o n   i s   d e s i g n e d   t o   b e   i n l i n a b l e ,   s o   p l e a s e   t a k e   c a r e   w h e n   m a k i n g   
 / /   c h a n g e s   t o   t h e   f u n c t i o n   b o d y .   
 f u n c t i o n   f r o m L i s t ( n ,   s t a t e )   {   
     / /   n o t h i n g   b u f f e r e d   
     i f   ( s t a t e . l e n g t h   = = =   0 )   
         r e t u r n   n u l l ;   
   
     v a r   r e t ;   
     i f   ( s t a t e . o b j e c t M o d e )   
         r e t   =   s t a t e . b u f f e r . s h i f t ( ) ;   
     e l s e   i f   ( ! n   | |   n   > =   s t a t e . l e n g t h )   {   
         / /   r e a d   i t   a l l ,   t r u n c a t e   t h e   l i s t   
         i f   ( s t a t e . d e c o d e r )   
             r e t   =   s t a t e . b u f f e r . j o i n ( ' ' ) ;   
         e l s e   i f   ( s t a t e . b u f f e r . l e n g t h   = = =   1 )   
             r e t   =   s t a t e . b u f f e r . h e a d . d a t a ;   
         e l s e   
             r e t   =   s t a t e . b u f f e r . c o n c a t ( s t a t e . l e n g t h ) ;   
         s t a t e . b u f f e r . c l e a r ( ) ;   
     }   e l s e   {   
         / /   r e a d   p a r t   o f   l i s t   
         r e t   =   f r o m L i s t P a r t i a l ( n ,   s t a t e . b u f f e r ,   s t a t e . d e c o d e r ) ;   
     }   
   
     r e t u r n   r e t ;   
 }   
   
 / /   E x t r a c t s   o n l y   e n o u g h   b u f f e r e d   d a t a   t o   s a t i s f y   t h e   a m o u n t   r e q u e s t e d .   
 / /   T h i s   f u n c t i o n   i s   d e s i g n e d   t o   b e   i n l i n a b l e ,   s o   p l e a s e   t a k e   c a r e   w h e n   m a k i n g   
 / /   c h a n g e s   t o   t h e   f u n c t i o n   b o d y .   
 f u n c t i o n   f r o m L i s t P a r t i a l ( n ,   l i s t ,   h a s S t r i n g s )   {   
     v a r   r e t ;   
     i f   ( n   <   l i s t . h e a d . d a t a . l e n g t h )   {   
         / /   s l i c e   i s   t h e   s a m e   f o r   b u f f e r s   a n d   s t r i n g s   
         r e t   =   l i s t . h e a d . d a t a . s l i c e ( 0 ,   n ) ;   
         l i s t . h e a d . d a t a   =   l i s t . h e a d . d a t a . s l i c e ( n ) ;   
     }   e l s e   i f   ( n   = = =   l i s t . h e a d . d a t a . l e n g t h )   {   
         / /   f i r s t   c h u n k   i s   a   p e r f e c t   m a t c h   
         r e t   =   l i s t . s h i f t ( ) ;   
     }   e l s e   {   
         / /   r e s u l t   s p a n s   m o r e   t h a n   o n e   b u f f e r   
         r e t   =   ( h a s S t r i n g s   
                       ?   c o p y F r o m B u f f e r S t r i n g ( n ,   l i s t )   
                       :   c o p y F r o m B u f f e r ( n ,   l i s t ) ) ;   
     }   
     r e t u r n   r e t ;   
 }   
   
 / /   C o p i e s   a   s p e c i f i e d   a m o u n t   o f   c h a r a c t e r s   f r o m   t h e   l i s t   o f   b u f f e r e d   d a t a   
 / /   c h u n k s .   
 / /   T h i s   f u n c t i o n   i s   d e s i g n e d   t o   b e   i n l i n a b l e ,   s o   p l e a s e   t a k e   c a r e   w h e n   m a k i n g   
 / /   c h a n g e s   t o   t h e   f u n c t i o n   b o d y .   
 f u n c t i o n   c o p y F r o m B u f f e r S t r i n g ( n ,   l i s t )   {   
     v a r   p   =   l i s t . h e a d ;   
     v a r   c   =   1 ;   
     v a r   r e t   =   p . d a t a ;   
     n   - =   r e t . l e n g t h ;   
     w h i l e   ( p   =   p . n e x t )   {   
         c o n s t   s t r   =   p . d a t a ;   
         c o n s t   n b   =   ( n   >   s t r . l e n g t h   ?   s t r . l e n g t h   :   n ) ;   
         i f   ( n b   = = =   s t r . l e n g t h )   
             r e t   + =   s t r ;   
         e l s e   
             r e t   + =   s t r . s l i c e ( 0 ,   n ) ;   
         n   - =   n b ;   
         i f   ( n   = = =   0 )   {   
             i f   ( n b   = = =   s t r . l e n g t h )   {   
                 + + c ;   
                 i f   ( p . n e x t )   
                     l i s t . h e a d   =   p . n e x t ;   
                 e l s e   
                     l i s t . h e a d   =   l i s t . t a i l   =   n u l l ;   
             }   e l s e   {   
                 l i s t . h e a d   =   p ;   
                 p . d a t a   =   s t r . s l i c e ( n b ) ;   
             }   
             b r e a k ;   
         }   
         + + c ;   
     }   
     l i s t . l e n g t h   - =   c ;   
     r e t u r n   r e t ;   
 }   
   
 / /   C o p i e s   a   s p e c i f i e d   a m o u n t   o f   b y t e s   f r o m   t h e   l i s t   o f   b u f f e r e d   d a t a   c h u n k s .   
 / /   T h i s   f u n c t i o n   i s   d e s i g n e d   t o   b e   i n l i n a b l e ,   s o   p l e a s e   t a k e   c a r e   w h e n   m a k i n g   
 / /   c h a n g e s   t o   t h e   f u n c t i o n   b o d y .   
 f u n c t i o n   c o p y F r o m B u f f e r ( n ,   l i s t )   {   
     c o n s t   r e t   =   B u f f e r . a l l o c U n s a f e ( n ) ;   
     v a r   p   =   l i s t . h e a d ;   
     v a r   c   =   1 ;   
     p . d a t a . c o p y ( r e t ) ;   
     n   - =   p . d a t a . l e n g t h ;   
     w h i l e   ( p   =   p . n e x t )   {   
         c o n s t   b u f   =   p . d a t a ;   
         c o n s t   n b   =   ( n   >   b u f . l e n g t h   ?   b u f . l e n g t h   :   n ) ;   
         b u f . c o p y ( r e t ,   r e t . l e n g t h   -   n ,   0 ,   n b ) ;   
         n   - =   n b ;   
         i f   ( n   = = =   0 )   {   
             i f   ( n b   = = =   b u f . l e n g t h )   {   
                 + + c ;   
                 i f   ( p . n e x t )   
                     l i s t . h e a d   =   p . n e x t ;   
                 e l s e   
                     l i s t . h e a d   =   l i s t . t a i l   =   n u l l ;   
             }   e l s e   {   
                 l i s t . h e a d   =   p ;   
                 p . d a t a   =   b u f . s l i c e ( n b ) ;   
             }   
             b r e a k ;   
         }   
         + + c ;   
     }   
     l i s t . l e n g t h   - =   c ;   
     r e t u r n   r e t ;   
 }   
   
 f u n c t i o n   e n d R e a d a b l e ( s t r e a m )   {   
     v a r   s t a t e   =   s t r e a m . _ r e a d a b l e S t a t e ;   
   
     / /   I f   w e   g e t   h e r e   b e f o r e   c o n s u m i n g   a l l   t h e   b y t e s ,   t h e n   t h a t   i s   a   
     / /   b u g   i n   n o d e .     S h o u l d   n e v e r   h a p p e n .   
     i f   ( s t a t e . l e n g t h   >   0 )   
         t h r o w   n e w   E r r o r ( ' " e n d R e a d a b l e ( ) "   c a l l e d   o n   n o n - e m p t y   s t r e a m ' ) ;   
   
     i f   ( ! s t a t e . e n d E m i t t e d )   {   
         s t a t e . e n d e d   =   t r u e ;   
         p r o c e s s . n e x t T i c k ( e n d R e a d a b l e N T ,   s t a t e ,   s t r e a m ) ;   
     }   
 }   
   
 f u n c t i o n   e n d R e a d a b l e N T ( s t a t e ,   s t r e a m )   {   
     / /   C h e c k   t h a t   w e   d i d n ' t   g e t   o n e   l a s t   u n s h i f t .   
     i f   ( ! s t a t e . e n d E m i t t e d   & &   s t a t e . l e n g t h   = = =   0 )   {   
         s t a t e . e n d E m i t t e d   =   t r u e ;   
         s t r e a m . r e a d a b l e   =   f a l s e ;   
         s t r e a m . e m i t ( ' e n d ' ) ;   
     }   
 }   
 
 } ) ; L4  `   ��
 N O D E _ M O D U L E S / _ S T R E A M _ T R A N S F O R M . J S       0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / /   a   t r a n s f o r m   s t r e a m   i s   a   r e a d a b l e / w r i t a b l e   s t r e a m   w h e r e   y o u   d o   
 / /   s o m e t h i n g   w i t h   t h e   d a t a .     S o m e t i m e s   i t ' s   c a l l e d   a   " f i l t e r " ,   
 / /   b u t   t h a t ' s   n o t   a   g r e a t   n a m e   f o r   i t ,   s i n c e   t h a t   i m p l i e s   a   t h i n g   w h e r e   
 / /   s o m e   b i t s   p a s s   t h r o u g h ,   a n d   o t h e r s   a r e   s i m p l y   i g n o r e d .     ( T h a t   w o u l d   
 / /   b e   a   v a l i d   e x a m p l e   o f   a   t r a n s f o r m ,   o f   c o u r s e . )   
 / /   
 / /   W h i l e   t h e   o u t p u t   i s   c a u s a l l y   r e l a t e d   t o   t h e   i n p u t ,   i t ' s   n o t   a   
 / /   n e c e s s a r i l y   s y m m e t r i c   o r   s y n c h r o n o u s   t r a n s f o r m a t i o n .     F o r   e x a m p l e ,   
 / /   a   z l i b   s t r e a m   m i g h t   t a k e   m u l t i p l e   p l a i n - t e x t   w r i t e s ( ) ,   a n d   t h e n   
 / /   e m i t   a   s i n g l e   c o m p r e s s e d   c h u n k   s o m e   t i m e   i n   t h e   f u t u r e .   
 / /   
 / /   H e r e ' s   h o w   t h i s   w o r k s :   
 / /   
 / /   T h e   T r a n s f o r m   s t r e a m   h a s   a l l   t h e   a s p e c t s   o f   t h e   r e a d a b l e   a n d   w r i t a b l e   
 / /   s t r e a m   c l a s s e s .     W h e n   y o u   w r i t e ( c h u n k ) ,   t h a t   c a l l s   _ w r i t e ( c h u n k , c b )   
 / /   i n t e r n a l l y ,   a n d   r e t u r n s   f a l s e   i f   t h e r e ' s   a   l o t   o f   p e n d i n g   w r i t e s   
 / /   b u f f e r e d   u p .     W h e n   y o u   c a l l   r e a d ( ) ,   t h a t   c a l l s   _ r e a d ( n )   u n t i l   
 / /   t h e r e ' s   e n o u g h   p e n d i n g   r e a d a b l e   d a t a   b u f f e r e d   u p .   
 / /   
 / /   I n   a   t r a n s f o r m   s t r e a m ,   t h e   w r i t t e n   d a t a   i s   p l a c e d   i n   a   b u f f e r .     W h e n   
 / /   _ r e a d ( n )   i s   c a l l e d ,   i t   t r a n s f o r m s   t h e   q u e u e d   u p   d a t a ,   c a l l i n g   t h e   
 / /   b u f f e r e d   _ w r i t e   c b ' s   a s   i t   c o n s u m e s   c h u n k s .     I f   c o n s u m i n g   a   s i n g l e   
 / /   w r i t t e n   c h u n k   w o u l d   r e s u l t   i n   m u l t i p l e   o u t p u t   c h u n k s ,   t h e n   t h e   f i r s t   
 / /   o u t p u t t e d   b i t   c a l l s   t h e   r e a d c b ,   a n d   s u b s e q u e n t   c h u n k s   j u s t   g o   i n t o   
 / /   t h e   r e a d   b u f f e r ,   a n d   w i l l   c a u s e   i t   t o   e m i t   ' r e a d a b l e '   i f   n e c e s s a r y .   
 / /   
 / /   T h i s   w a y ,   b a c k - p r e s s u r e   i s   a c t u a l l y   d e t e r m i n e d   b y   t h e   r e a d i n g   s i d e ,   
 / /   s i n c e   _ r e a d   h a s   t o   b e   c a l l e d   t o   s t a r t   p r o c e s s i n g   a   n e w   c h u n k .     H o w e v e r ,   
 / /   a   p a t h o l o g i c a l   i n f l a t e   t y p e   o f   t r a n s f o r m   c a n   c a u s e   e x c e s s i v e   b u f f e r i n g   
 / /   h e r e .     F o r   e x a m p l e ,   i m a g i n e   a   s t r e a m   w h e r e   e v e r y   b y t e   o f   i n p u t   i s   
 / /   i n t e r p r e t e d   a s   a n   i n t e g e r   f r o m   0 - 2 5 5 ,   a n d   t h e n   r e s u l t s   i n   t h a t   m a n y   
 / /   b y t e s   o f   o u t p u t .     W r i t i n g   t h e   4   b y t e s   { f f , f f , f f , f f }   w o u l d   r e s u l t   i n   
 / /   1 k b   o f   d a t a   b e i n g   o u t p u t .     I n   t h i s   c a s e ,   y o u   c o u l d   w r i t e   a   v e r y   s m a l l   
 / /   a m o u n t   o f   i n p u t ,   a n d   e n d   u p   w i t h   a   v e r y   l a r g e   a m o u n t   o f   o u t p u t .     I n   
 / /   s u c h   a   p a t h o l o g i c a l   i n f l a t i n g   m e c h a n i s m ,   t h e r e ' d   b e   n o   w a y   t o   t e l l   
 / /   t h e   s y s t e m   t o   s t o p   d o i n g   t h e   t r a n s f o r m .     A   s i n g l e   4 M B   w r i t e   c o u l d   
 / /   c a u s e   t h e   s y s t e m   t o   r u n   o u t   o f   m e m o r y .   
 / /   
 / /   H o w e v e r ,   e v e n   i n   s u c h   a   p a t h o l o g i c a l   c a s e ,   o n l y   a   s i n g l e   w r i t t e n   c h u n k   
 / /   w o u l d   b e   c o n s u m e d ,   a n d   t h e n   t h e   r e s t   w o u l d   w a i t   ( u n - t r a n s f o r m e d )   u n t i l   
 / /   t h e   r e s u l t s   o f   t h e   p r e v i o u s   t r a n s f o r m e d   c h u n k   w e r e   c o n s u m e d .   
   
 ' u s e   s t r i c t ' ;   
   
 m o d u l e . e x p o r t s   =   T r a n s f o r m ;   
   
 c o n s t   D u p l e x   =   r e q u i r e ( ' _ s t r e a m _ d u p l e x ' ) ;   
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
 u t i l . i n h e r i t s ( T r a n s f o r m ,   D u p l e x ) ;   
   
   
 f u n c t i o n   T r a n s f o r m S t a t e ( s t r e a m )   {   
     t h i s . a f t e r T r a n s f o r m   =   f u n c t i o n ( e r ,   d a t a )   {   
         r e t u r n   a f t e r T r a n s f o r m ( s t r e a m ,   e r ,   d a t a ) ;   
     } ;   
   
     t h i s . n e e d T r a n s f o r m   =   f a l s e ;   
     t h i s . t r a n s f o r m i n g   =   f a l s e ;   
     t h i s . w r i t e c b   =   n u l l ;   
     t h i s . w r i t e c h u n k   =   n u l l ;   
     t h i s . w r i t e e n c o d i n g   =   n u l l ;   
 }   
   
 f u n c t i o n   a f t e r T r a n s f o r m ( s t r e a m ,   e r ,   d a t a )   {   
     v a r   t s   =   s t r e a m . _ t r a n s f o r m S t a t e ;   
     t s . t r a n s f o r m i n g   =   f a l s e ;   
   
     v a r   c b   =   t s . w r i t e c b ;   
   
     i f   ( ! c b )   
         r e t u r n   s t r e a m . e m i t ( ' e r r o r ' ,   n e w   E r r o r ( ' n o   w r i t e c b   i n   T r a n s f o r m   c l a s s ' ) ) ;   
   
     t s . w r i t e c h u n k   =   n u l l ;   
     t s . w r i t e c b   =   n u l l ;   
   
     i f   ( d a t a   ! = =   n u l l   & &   d a t a   ! = =   u n d e f i n e d )   
         s t r e a m . p u s h ( d a t a ) ;   
   
     c b ( e r ) ;   
   
     v a r   r s   =   s t r e a m . _ r e a d a b l e S t a t e ;   
     r s . r e a d i n g   =   f a l s e ;   
     i f   ( r s . n e e d R e a d a b l e   | |   r s . l e n g t h   <   r s . h i g h W a t e r M a r k )   {   
         s t r e a m . _ r e a d ( r s . h i g h W a t e r M a r k ) ;   
     }   
 }   
   
   
 f u n c t i o n   T r a n s f o r m ( o p t i o n s )   {   
     i f   ( ! ( t h i s   i n s t a n c e o f   T r a n s f o r m ) )   
         r e t u r n   n e w   T r a n s f o r m ( o p t i o n s ) ;   
   
     D u p l e x . c a l l ( t h i s ,   o p t i o n s ) ;   
   
     t h i s . _ t r a n s f o r m S t a t e   =   n e w   T r a n s f o r m S t a t e ( t h i s ) ;   
   
     / /   w h e n   t h e   w r i t a b l e   s i d e   f i n i s h e s ,   t h e n   f l u s h   o u t   a n y t h i n g   r e m a i n i n g .   
     v a r   s t r e a m   =   t h i s ;   
   
     / /   s t a r t   o u t   a s k i n g   f o r   a   r e a d a b l e   e v e n t   o n c e   d a t a   i s   t r a n s f o r m e d .   
     t h i s . _ r e a d a b l e S t a t e . n e e d R e a d a b l e   =   t r u e ;   
   
     / /   w e   h a v e   i m p l e m e n t e d   t h e   _ r e a d   m e t h o d ,   a n d   d o n e   t h e   o t h e r   t h i n g s   
     / /   t h a t   R e a d a b l e   w a n t s   b e f o r e   t h e   f i r s t   _ r e a d   c a l l ,   s o   u n s e t   t h e   
     / /   s y n c   g u a r d   f l a g .   
     t h i s . _ r e a d a b l e S t a t e . s y n c   =   f a l s e ;   
   
     i f   ( o p t i o n s )   {   
         i f   ( t y p e o f   o p t i o n s . t r a n s f o r m   = = =   ' f u n c t i o n ' )   
             t h i s . _ t r a n s f o r m   =   o p t i o n s . t r a n s f o r m ;   
   
         i f   ( t y p e o f   o p t i o n s . f l u s h   = = =   ' f u n c t i o n ' )   
             t h i s . _ f l u s h   =   o p t i o n s . f l u s h ;   
     }   
   
     t h i s . o n c e ( ' p r e f i n i s h ' ,   f u n c t i o n ( )   {   
         i f   ( t y p e o f   t h i s . _ f l u s h   = = =   ' f u n c t i o n ' )   
             t h i s . _ f l u s h ( f u n c t i o n ( e r ,   d a t a )   {   
                 d o n e ( s t r e a m ,   e r ,   d a t a ) ;   
             } ) ;   
         e l s e   
             d o n e ( s t r e a m ) ;   
     } ) ;   
 }   
   
 T r a n s f o r m . p r o t o t y p e . p u s h   =   f u n c t i o n ( c h u n k ,   e n c o d i n g )   {   
     t h i s . _ t r a n s f o r m S t a t e . n e e d T r a n s f o r m   =   f a l s e ;   
     r e t u r n   D u p l e x . p r o t o t y p e . p u s h . c a l l ( t h i s ,   c h u n k ,   e n c o d i n g ) ;   
 } ;   
   
 / /   T h i s   i s   t h e   p a r t   w h e r e   y o u   d o   s t u f f !   
 / /   o v e r r i d e   t h i s   f u n c t i o n   i n   i m p l e m e n t a t i o n   c l a s s e s .   
 / /   ' c h u n k '   i s   a n   i n p u t   c h u n k .   
 / /   
 / /   C a l l   ` p u s h ( n e w C h u n k ) `   t o   p a s s   a l o n g   t r a n s f o r m e d   o u t p u t   
 / /   t o   t h e   r e a d a b l e   s i d e .     Y o u   m a y   c a l l   ' p u s h '   z e r o   o r   m o r e   t i m e s .   
 / /   
 / /   C a l l   ` c b ( e r r ) `   w h e n   y o u   a r e   d o n e   w i t h   t h i s   c h u n k .     I f   y o u   p a s s   
 / /   a n   e r r o r ,   t h e n   t h a t ' l l   p u t   t h e   h u r t   o n   t h e   w h o l e   o p e r a t i o n .     I f   y o u   
 / /   n e v e r   c a l l   c b ( ) ,   t h e n   y o u ' l l   n e v e r   g e t   a n o t h e r   c h u n k .   
 T r a n s f o r m . p r o t o t y p e . _ t r a n s f o r m   =   f u n c t i o n ( c h u n k ,   e n c o d i n g ,   c b )   {   
     t h r o w   n e w   E r r o r ( ' N o t   i m p l e m e n t e d ' ) ;   
 } ;   
   
 T r a n s f o r m . p r o t o t y p e . _ w r i t e   =   f u n c t i o n ( c h u n k ,   e n c o d i n g ,   c b )   {   
     v a r   t s   =   t h i s . _ t r a n s f o r m S t a t e ;   
     t s . w r i t e c b   =   c b ;   
     t s . w r i t e c h u n k   =   c h u n k ;   
     t s . w r i t e e n c o d i n g   =   e n c o d i n g ;   
     i f   ( ! t s . t r a n s f o r m i n g )   {   
         v a r   r s   =   t h i s . _ r e a d a b l e S t a t e ;   
         i f   ( t s . n e e d T r a n s f o r m   | |   
                 r s . n e e d R e a d a b l e   | |   
                 r s . l e n g t h   <   r s . h i g h W a t e r M a r k )   
             t h i s . _ r e a d ( r s . h i g h W a t e r M a r k ) ;   
     }   
 } ;   
   
 / /   D o e s n ' t   m a t t e r   w h a t   t h e   a r g s   a r e   h e r e .   
 / /   _ t r a n s f o r m   d o e s   a l l   t h e   w o r k .   
 / /   T h a t   w e   g o t   h e r e   m e a n s   t h a t   t h e   r e a d a b l e   s i d e   w a n t s   m o r e   d a t a .   
 T r a n s f o r m . p r o t o t y p e . _ r e a d   =   f u n c t i o n ( n )   {   
     v a r   t s   =   t h i s . _ t r a n s f o r m S t a t e ;   
   
     i f   ( t s . w r i t e c h u n k   ! = =   n u l l   & &   t s . w r i t e c b   & &   ! t s . t r a n s f o r m i n g )   {   
         t s . t r a n s f o r m i n g   =   t r u e ;   
         t h i s . _ t r a n s f o r m ( t s . w r i t e c h u n k ,   t s . w r i t e e n c o d i n g ,   t s . a f t e r T r a n s f o r m ) ;   
     }   e l s e   {   
         / /   m a r k   t h a t   w e   n e e d   a   t r a n s f o r m ,   s o   t h a t   a n y   d a t a   t h a t   c o m e s   i n   
         / /   w i l l   g e t   p r o c e s s e d ,   n o w   t h a t   w e ' v e   a s k e d   f o r   i t .   
         t s . n e e d T r a n s f o r m   =   t r u e ;   
     }   
 } ;   
   
   
 f u n c t i o n   d o n e ( s t r e a m ,   e r ,   d a t a )   {   
     i f   ( e r )   
         r e t u r n   s t r e a m . e m i t ( ' e r r o r ' ,   e r ) ;   
   
     i f   ( d a t a   ! = =   n u l l   & &   d a t a   ! = =   u n d e f i n e d )   
         s t r e a m . p u s h ( d a t a ) ;   
   
     / /   i f   t h e r e ' s   n o t h i n g   i n   t h e   w r i t e   b u f f e r ,   t h e n   t h a t   m e a n s   
     / /   t h a t   n o t h i n g   m o r e   w i l l   e v e r   b e   p r o v i d e d   
     v a r   w s   =   s t r e a m . _ w r i t a b l e S t a t e ;   
     v a r   t s   =   s t r e a m . _ t r a n s f o r m S t a t e ;   
   
     i f   ( w s . l e n g t h )   
         t h r o w   n e w   E r r o r ( ' C a l l i n g   t r a n s f o r m   d o n e   w h e n   w s . l e n g t h   ! =   0 ' ) ;   
   
     i f   ( t s . t r a n s f o r m i n g )   
         t h r o w   n e w   E r r o r ( ' C a l l i n g   t r a n s f o r m   d o n e   w h e n   s t i l l   t r a n s f o r m i n g ' ) ;   
   
     r e t u r n   s t r e a m . p u s h ( n u l l ) ;   
 }   
 
 } ) ; �t  `   ��
 N O D E _ M O D U L E S / _ S T R E A M _ W R I T A B L E . J S         0	        ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   / /   A   b i t   s i m p l e r   t h a n   r e a d a b l e   s t r e a m s .   
 / /   I m p l e m e n t   a n   a s y n c   . _ w r i t e ( c h u n k ,   e n c o d i n g ,   c b ) ,   a n d   i t ' l l   h a n d l e   a l l   
 / /   t h e   d r a i n   e v e n t   e m i s s i o n   a n d   b u f f e r i n g .   
   
 ' u s e   s t r i c t ' ;   
   
 m o d u l e . e x p o r t s   =   W r i t a b l e ;   
 W r i t a b l e . W r i t a b l e S t a t e   =   W r i t a b l e S t a t e ;   
   
 c o n s t   u t i l   =   r e q u i r e ( ' u t i l ' ) ;   
 c o n s t   i n t e r n a l U t i l   =   r e q u i r e ( ' i n t e r n a l / u t i l ' ) ;   
 c o n s t   S t r e a m   =   r e q u i r e ( ' s t r e a m ' ) ;   
 c o n s t   B u f f e r   =   r e q u i r e ( ' b u f f e r ' ) . B u f f e r ;   
   
 u t i l . i n h e r i t s ( W r i t a b l e ,   S t r e a m ) ;   
   
 f u n c t i o n   n o p ( )   { }   
   
 f u n c t i o n   W r i t e R e q ( c h u n k ,   e n c o d i n g ,   c b )   {   
     t h i s . c h u n k   =   c h u n k ;   
     t h i s . e n c o d i n g   =   e n c o d i n g ;   
     t h i s . c a l l b a c k   =   c b ;   
     t h i s . n e x t   =   n u l l ;   
 }   
   
 f u n c t i o n   W r i t a b l e S t a t e ( o p t i o n s ,   s t r e a m )   {   
     o p t i o n s   =   o p t i o n s   | |   { } ;   
   
     / /   o b j e c t   s t r e a m   f l a g   t o   i n d i c a t e   w h e t h e r   o r   n o t   t h i s   s t r e a m   
     / /   c o n t a i n s   b u f f e r s   o r   o b j e c t s .   
     t h i s . o b j e c t M o d e   =   ! ! o p t i o n s . o b j e c t M o d e ;   
   
     i f   ( s t r e a m   i n s t a n c e o f   S t r e a m . D u p l e x )   
         t h i s . o b j e c t M o d e   =   t h i s . o b j e c t M o d e   | |   ! ! o p t i o n s . w r i t a b l e O b j e c t M o d e ;   
   
     / /   t h e   p o i n t   a t   w h i c h   w r i t e ( )   s t a r t s   r e t u r n i n g   f a l s e   
     / /   N o t e :   0   i s   a   v a l i d   v a l u e ,   m e a n s   t h a t   w e   a l w a y s   r e t u r n   f a l s e   i f   
     / /   t h e   e n t i r e   b u f f e r   i s   n o t   f l u s h e d   i m m e d i a t e l y   o n   w r i t e ( )   
     v a r   h w m   =   o p t i o n s . h i g h W a t e r M a r k ;   
     v a r   d e f a u l t H w m   =   t h i s . o b j e c t M o d e   ?   1 6   :   1 6   *   1 0 2 4 ;   
     t h i s . h i g h W a t e r M a r k   =   ( h w m   | |   h w m   = = =   0 )   ?   h w m   :   d e f a u l t H w m ;   
   
     / /   c a s t   t o   i n t s .   
     t h i s . h i g h W a t e r M a r k   =   ~ ~ t h i s . h i g h W a t e r M a r k ;   
   
     t h i s . n e e d D r a i n   =   f a l s e ;   
     / /   a t   t h e   s t a r t   o f   c a l l i n g   e n d ( )   
     t h i s . e n d i n g   =   f a l s e ;   
     / /   w h e n   e n d ( )   h a s   b e e n   c a l l e d ,   a n d   r e t u r n e d   
     t h i s . e n d e d   =   f a l s e ;   
     / /   w h e n   ' f i n i s h '   i s   e m i t t e d   
     t h i s . f i n i s h e d   =   f a l s e ;   
   
     / /   s h o u l d   w e   d e c o d e   s t r i n g s   i n t o   b u f f e r s   b e f o r e   p a s s i n g   t o   _ w r i t e ?   
     / /   t h i s   i s   h e r e   s o   t h a t   s o m e   n o d e - c o r e   s t r e a m s   c a n   o p t i m i z e   s t r i n g   
     / /   h a n d l i n g   a t   a   l o w e r   l e v e l .   
     v a r   n o D e c o d e   =   o p t i o n s . d e c o d e S t r i n g s   = = =   f a l s e ;   
     t h i s . d e c o d e S t r i n g s   =   ! n o D e c o d e ;   
   
     / /   C r y p t o   i s   k i n d   o f   o l d   a n d   c r u s t y .     H i s t o r i c a l l y ,   i t s   d e f a u l t   s t r i n g   
     / /   e n c o d i n g   i s   ' b i n a r y '   s o   w e   h a v e   t o   m a k e   t h i s   c o n f i g u r a b l e .   
     / /   E v e r y t h i n g   e l s e   i n   t h e   u n i v e r s e   u s e s   ' u t f 8 ' ,   t h o u g h .   
     t h i s . d e f a u l t E n c o d i n g   =   o p t i o n s . d e f a u l t E n c o d i n g   | |   ' u t f 8 ' ;   
   
     / /   n o t   a n   a c t u a l   b u f f e r   w e   k e e p   t r a c k   o f ,   b u t   a   m e a s u r e m e n t   
     / /   o f   h o w   m u c h   w e ' r e   w a i t i n g   t o   g e t   p u s h e d   t o   s o m e   u n d e r l y i n g   
     / /   s o c k e t   o r   f i l e .   
     t h i s . l e n g t h   =   0 ;   
   
     / /   a   f l a g   t o   s e e   w h e n   w e ' r e   i n   t h e   m i d d l e   o f   a   w r i t e .   
     t h i s . w r i t i n g   =   f a l s e ;   
   
     / /   w h e n   t r u e   a l l   w r i t e s   w i l l   b e   b u f f e r e d   u n t i l   . u n c o r k ( )   c a l l   
     t h i s . c o r k e d   =   0 ;   
   
     / /   a   f l a g   t o   b e   a b l e   t o   t e l l   i f   t h e   o n w r i t e   c b   i s   c a l l e d   i m m e d i a t e l y ,   
     / /   o r   o n   a   l a t e r   t i c k .     W e   s e t   t h i s   t o   t r u e   a t   f i r s t ,   b e c a u s e   a n y   
     / /   a c t i o n s   t h a t   s h o u l d n ' t   h a p p e n   u n t i l   " l a t e r "   s h o u l d   g e n e r a l l y   a l s o   
     / /   n o t   h a p p e n   b e f o r e   t h e   f i r s t   w r i t e   c a l l .   
     t h i s . s y n c   =   t r u e ;   
   
     / /   a   f l a g   t o   k n o w   i f   w e ' r e   p r o c e s s i n g   p r e v i o u s l y   b u f f e r e d   i t e m s ,   w h i c h   
     / /   m a y   c a l l   t h e   _ w r i t e ( )   c a l l b a c k   i n   t h e   s a m e   t i c k ,   s o   t h a t   w e   d o n ' t   
     / /   e n d   u p   i n   a n   o v e r l a p p e d   o n w r i t e   s i t u a t i o n .   
     t h i s . b u f f e r P r o c e s s i n g   =   f a l s e ;   
   
     / /   t h e   c a l l b a c k   t h a t ' s   p a s s e d   t o   _ w r i t e ( c h u n k , c b )   
     t h i s . o n w r i t e   =   f u n c t i o n ( e r )   {   
         o n w r i t e ( s t r e a m ,   e r ) ;   
     } ;   
   
     / /   t h e   c a l l b a c k   t h a t   t h e   u s e r   s u p p l i e s   t o   w r i t e ( c h u n k , e n c o d i n g , c b )   
     t h i s . w r i t e c b   =   n u l l ;   
   
     / /   t h e   a m o u n t   t h a t   i s   b e i n g   w r i t t e n   w h e n   _ w r i t e   i s   c a l l e d .   
     t h i s . w r i t e l e n   =   0 ;   
   
     t h i s . b u f f e r e d R e q u e s t   =   n u l l ;   
     t h i s . l a s t B u f f e r e d R e q u e s t   =   n u l l ;   
   
     / /   n u m b e r   o f   p e n d i n g   u s e r - s u p p l i e d   w r i t e   c a l l b a c k s   
     / /   t h i s   m u s t   b e   0   b e f o r e   ' f i n i s h '   c a n   b e   e m i t t e d   
     t h i s . p e n d i n g c b   =   0 ;   
   
     / /   e m i t   p r e f i n i s h   i f   t h e   o n l y   t h i n g   w e ' r e   w a i t i n g   f o r   i s   _ w r i t e   c b s   
     / /   T h i s   i s   r e l e v a n t   f o r   s y n c h r o n o u s   T r a n s f o r m   s t r e a m s   
     t h i s . p r e f i n i s h e d   =   f a l s e ;   
   
     / /   T r u e   i f   t h e   e r r o r   w a s   a l r e a d y   e m i t t e d   a n d   s h o u l d   n o t   b e   t h r o w n   a g a i n   
     t h i s . e r r o r E m i t t e d   =   f a l s e ;   
   
     / /   c o u n t   b u f f e r e d   r e q u e s t s   
     t h i s . b u f f e r e d R e q u e s t C o u n t   =   0 ;   
   
     / /   a l l o c a t e   t h e   f i r s t   C o r k e d R e q u e s t ,   t h e r e   i s   a l w a y s   
     / /   o n e   a l l o c a t e d   a n d   f r e e   t o   u s e ,   a n d   w e   m a i n t a i n   a t   m o s t   t w o   
     t h i s . c o r k e d R e q u e s t s F r e e   =   n e w   C o r k e d R e q u e s t ( t h i s ) ;   
 }   
   
 W r i t a b l e S t a t e . p r o t o t y p e . g e t B u f f e r   =   f u n c t i o n   w r i t a b l e S t a t e G e t B u f f e r ( )   {   
     v a r   c u r r e n t   =   t h i s . b u f f e r e d R e q u e s t ;   
     v a r   o u t   =   [ ] ;   
     w h i l e   ( c u r r e n t )   {   
         o u t . p u s h ( c u r r e n t ) ;   
         c u r r e n t   =   c u r r e n t . n e x t ;   
     }   
     r e t u r n   o u t ;   
 } ;   
   
 O b j e c t . d e f i n e P r o p e r t y ( W r i t a b l e S t a t e . p r o t o t y p e ,   ' b u f f e r ' ,   {   
     g e t :   i n t e r n a l U t i l . d e p r e c a t e ( f u n c t i o n ( )   {   
         r e t u r n   t h i s . g e t B u f f e r ( ) ;   
     } ,   ' _ w r i t a b l e S t a t e . b u f f e r   i s   d e p r e c a t e d .   U s e   _ w r i t a b l e S t a t e . g e t B u f f e r   '   +   
           ' i n s t e a d . ' )   
 } ) ;   
   
 f u n c t i o n   W r i t a b l e ( o p t i o n s )   {   
     / /   W r i t a b l e   c t o r   i s   a p p l i e d   t o   D u p l e x e s ,   t h o u g h   t h e y ' r e   n o t   
     / /   i n s t a n c e o f   W r i t a b l e ,   t h e y ' r e   i n s t a n c e o f   R e a d a b l e .   
     i f   ( ! ( t h i s   i n s t a n c e o f   W r i t a b l e )   & &   ! ( t h i s   i n s t a n c e o f   S t r e a m . D u p l e x ) )   
         r e t u r n   n e w   W r i t a b l e ( o p t i o n s ) ;   
   
     t h i s . _ w r i t a b l e S t a t e   =   n e w   W r i t a b l e S t a t e ( o p t i o n s ,   t h i s ) ;   
   
     / /   l e g a c y .   
     t h i s . w r i t a b l e   =   t r u e ;   
   
     i f   ( o p t i o n s )   {   
         i f   ( t y p e o f   o p t i o n s . w r i t e   = = =   ' f u n c t i o n ' )   
             t h i s . _ w r i t e   =   o p t i o n s . w r i t e ;   
   
         i f   ( t y p e o f   o p t i o n s . w r i t e v   = = =   ' f u n c t i o n ' )   
             t h i s . _ w r i t e v   =   o p t i o n s . w r i t e v ;   
     }   
   
     S t r e a m . c a l l ( t h i s ) ;   
 }   
   
 / /   O t h e r w i s e   p e o p l e   c a n   p i p e   W r i t a b l e   s t r e a m s ,   w h i c h   i s   j u s t   w r o n g .   
 W r i t a b l e . p r o t o t y p e . p i p e   =   f u n c t i o n ( )   {   
     t h i s . e m i t ( ' e r r o r ' ,   n e w   E r r o r ( ' C a n n o t   p i p e ,   n o t   r e a d a b l e ' ) ) ;   
 } ;   
   
   
 f u n c t i o n   w r i t e A f t e r E n d ( s t r e a m ,   c b )   {   
     v a r   e r   =   n e w   E r r o r ( ' w r i t e   a f t e r   e n d ' ) ;   
     / /   T O D O :   d e f e r   e r r o r   e v e n t s   c o n s i s t e n t l y   e v e r y w h e r e ,   n o t   j u s t   t h e   c b   
     s t r e a m . e m i t ( ' e r r o r ' ,   e r ) ;   
     p r o c e s s . n e x t T i c k ( c b ,   e r ) ;   
 }   
   
 / /   I f   w e   g e t   s o m e t h i n g   t h a t   i s   n o t   a   b u f f e r ,   s t r i n g ,   n u l l ,   o r   u n d e f i n e d ,   
 / /   a n d   w e ' r e   n o t   i n   o b j e c t M o d e ,   t h e n   t h a t ' s   a n   e r r o r .   
 / /   O t h e r w i s e   s t r e a m   c h u n k s   a r e   a l l   c o n s i d e r e d   t o   b e   o f   l e n g t h = 1 ,   a n d   t h e   
 / /   w a t e r m a r k s   d e t e r m i n e   h o w   m a n y   o b j e c t s   t o   k e e p   i n   t h e   b u f f e r ,   r a t h e r   t h a n   
 / /   h o w   m a n y   b y t e s   o r   c h a r a c t e r s .   
 f u n c t i o n   v a l i d C h u n k ( s t r e a m ,   s t a t e ,   c h u n k ,   c b )   {   
     v a r   v a l i d   =   t r u e ;   
     v a r   e r   =   f a l s e ;   
     / /   A l w a y s   t h r o w   e r r o r   i f   a   n u l l   i s   w r i t t e n   
     / /   i f   w e   a r e   n o t   i n   o b j e c t   m o d e   t h e n   t h r o w   
     / /   i f   i t   i s   n o t   a   b u f f e r ,   s t r i n g ,   o r   u n d e f i n e d .   
     i f   ( c h u n k   = = =   n u l l )   {   
         e r   =   n e w   T y p e E r r o r ( ' M a y   n o t   w r i t e   n u l l   v a l u e s   t o   s t r e a m ' ) ;   
     }   e l s e   i f   ( ! ( c h u n k   i n s t a n c e o f   B u f f e r )   & &   
             t y p e o f   c h u n k   ! = =   ' s t r i n g '   & &   
             c h u n k   ! = =   u n d e f i n e d   & &   
             ! s t a t e . o b j e c t M o d e )   {   
         e r   =   n e w   T y p e E r r o r ( ' I n v a l i d   n o n - s t r i n g / b u f f e r   c h u n k ' ) ;   
     }   
     i f   ( e r )   {   
         s t r e a m . e m i t ( ' e r r o r ' ,   e r ) ;   
         p r o c e s s . n e x t T i c k ( c b ,   e r ) ;   
         v a l i d   =   f a l s e ;   
     }   
     r e t u r n   v a l i d ;   
 }   
   
 W r i t a b l e . p r o t o t y p e . w r i t e   =   f u n c t i o n ( c h u n k ,   e n c o d i n g ,   c b )   {   
     v a r   s t a t e   =   t h i s . _ w r i t a b l e S t a t e ;   
     v a r   r e t   =   f a l s e ;   
   
     i f   ( t y p e o f   e n c o d i n g   = = =   ' f u n c t i o n ' )   {   
         c b   =   e n c o d i n g ;   
         e n c o d i n g   =   n u l l ;   
     }   
   
     i f   ( c h u n k   i n s t a n c e o f   B u f f e r )   
         e n c o d i n g   =   ' b u f f e r ' ;   
     e l s e   i f   ( ! e n c o d i n g )   
         e n c o d i n g   =   s t a t e . d e f a u l t E n c o d i n g ;   
   
     i f   ( t y p e o f   c b   ! = =   ' f u n c t i o n ' )   
         c b   =   n o p ;   
   
     i f   ( s t a t e . e n d e d )   
         w r i t e A f t e r E n d ( t h i s ,   c b ) ;   
     e l s e   i f   ( v a l i d C h u n k ( t h i s ,   s t a t e ,   c h u n k ,   c b ) )   {   
         s t a t e . p e n d i n g c b + + ;   
         r e t   =   w r i t e O r B u f f e r ( t h i s ,   s t a t e ,   c h u n k ,   e n c o d i n g ,   c b ) ;   
     }   
   
     r e t u r n   r e t ;   
 } ;   
   
 W r i t a b l e . p r o t o t y p e . c o r k   =   f u n c t i o n ( )   {   
     v a r   s t a t e   =   t h i s . _ w r i t a b l e S t a t e ;   
   
     s t a t e . c o r k e d + + ;   
 } ;   
   
 W r i t a b l e . p r o t o t y p e . u n c o r k   =   f u n c t i o n ( )   {   
     v a r   s t a t e   =   t h i s . _ w r i t a b l e S t a t e ;   
   
     i f   ( s t a t e . c o r k e d )   {   
         s t a t e . c o r k e d - - ;   
   
         i f   ( ! s t a t e . w r i t i n g   & &   
                 ! s t a t e . c o r k e d   & &   
                 ! s t a t e . f i n i s h e d   & &   
                 ! s t a t e . b u f f e r P r o c e s s i n g   & &   
                 s t a t e . b u f f e r e d R e q u e s t )   
             c l e a r B u f f e r ( t h i s ,   s t a t e ) ;   
     }   
 } ;   
   
 W r i t a b l e . p r o t o t y p e . s e t D e f a u l t E n c o d i n g   =   f u n c t i o n   s e t D e f a u l t E n c o d i n g ( e n c o d i n g )   {   
     / /   n o d e : : P a r s e E n c o d i n g ( )   r e q u i r e s   l o w e r   c a s e .   
     i f   ( t y p e o f   e n c o d i n g   = = =   ' s t r i n g ' )   
         e n c o d i n g   =   e n c o d i n g . t o L o w e r C a s e ( ) ;   
     i f   ( ! B u f f e r . i s E n c o d i n g ( e n c o d i n g ) )   
         t h r o w   n e w   T y p e E r r o r ( ' U n k n o w n   e n c o d i n g :   '   +   e n c o d i n g ) ;   
     t h i s . _ w r i t a b l e S t a t e . d e f a u l t E n c o d i n g   =   e n c o d i n g ;   
     r e t u r n   t h i s ;   
 } ;   
   
 f u n c t i o n   d e c o d e C h u n k ( s t a t e ,   c h u n k ,   e n c o d i n g )   {   
     i f   ( ! s t a t e . o b j e c t M o d e   & &   
             s t a t e . d e c o d e S t r i n g s   ! = =   f a l s e   & &   
             t y p e o f   c h u n k   = = =   ' s t r i n g ' )   {   
         c h u n k   =   B u f f e r . f r o m ( c h u n k ,   e n c o d i n g ) ;   
     }   
     r e t u r n   c h u n k ;   
 }   
   
 / /   i f   w e ' r e   a l r e a d y   w r i t i n g   s o m e t h i n g ,   t h e n   j u s t   p u t   t h i s   
 / /   i n   t h e   q u e u e ,   a n d   w a i t   o u r   t u r n .     O t h e r w i s e ,   c a l l   _ w r i t e   
 / /   I f   w e   r e t u r n   f a l s e ,   t h e n   w e   n e e d   a   d r a i n   e v e n t ,   s o   s e t   t h a t   f l a g .   
 f u n c t i o n   w r i t e O r B u f f e r ( s t r e a m ,   s t a t e ,   c h u n k ,   e n c o d i n g ,   c b )   {   
     c h u n k   =   d e c o d e C h u n k ( s t a t e ,   c h u n k ,   e n c o d i n g ) ;   
   
     i f   ( c h u n k   i n s t a n c e o f   B u f f e r )   
         e n c o d i n g   =   ' b u f f e r ' ;   
     v a r   l e n   =   s t a t e . o b j e c t M o d e   ?   1   :   c h u n k . l e n g t h ;   
   
     s t a t e . l e n g t h   + =   l e n ;   
   
     v a r   r e t   =   s t a t e . l e n g t h   <   s t a t e . h i g h W a t e r M a r k ;   
     / /   w e   m u s t   e n s u r e   t h a t   p r e v i o u s   n e e d D r a i n   w i l l   n o t   b e   r e s e t   t o   f a l s e .   
     i f   ( ! r e t )   
         s t a t e . n e e d D r a i n   =   t r u e ;   
   
     i f   ( s t a t e . w r i t i n g   | |   s t a t e . c o r k e d )   {   
         v a r   l a s t   =   s t a t e . l a s t B u f f e r e d R e q u e s t ;   
         s t a t e . l a s t B u f f e r e d R e q u e s t   =   n e w   W r i t e R e q ( c h u n k ,   e n c o d i n g ,   c b ) ;   
         i f   ( l a s t )   {   
             l a s t . n e x t   =   s t a t e . l a s t B u f f e r e d R e q u e s t ;   
         }   e l s e   {   
             s t a t e . b u f f e r e d R e q u e s t   =   s t a t e . l a s t B u f f e r e d R e q u e s t ;   
         }   
         s t a t e . b u f f e r e d R e q u e s t C o u n t   + =   1 ;   
     }   e l s e   {   
         d o W r i t e ( s t r e a m ,   s t a t e ,   f a l s e ,   l e n ,   c h u n k ,   e n c o d i n g ,   c b ) ;   
     }   
   
     r e t u r n   r e t ;   
 }   
   
 f u n c t i o n   d o W r i t e ( s t r e a m ,   s t a t e ,   w r i t e v ,   l e n ,   c h u n k ,   e n c o d i n g ,   c b )   {   
     s t a t e . w r i t e l e n   =   l e n ;   
     s t a t e . w r i t e c b   =   c b ;   
     s t a t e . w r i t i n g   =   t r u e ;   
     s t a t e . s y n c   =   t r u e ;   
     i f   ( w r i t e v )   
         s t r e a m . _ w r i t e v ( c h u n k ,   s t a t e . o n w r i t e ) ;   
     e l s e   
         s t r e a m . _ w r i t e ( c h u n k ,   e n c o d i n g ,   s t a t e . o n w r i t e ) ;   
     s t a t e . s y n c   =   f a l s e ;   
 }   
   
 f u n c t i o n   o n w r i t e E r r o r ( s t r e a m ,   s t a t e ,   s y n c ,   e r ,   c b )   {   
     - - s t a t e . p e n d i n g c b ;   
     i f   ( s y n c )   
         p r o c e s s . n e x t T i c k ( c b ,   e r ) ;   
     e l s e   
         c b ( e r ) ;   
   
     s t r e a m . _ w r i t a b l e S t a t e . e r r o r E m i t t e d   =   t r u e ;   
     s t r e a m . e m i t ( ' e r r o r ' ,   e r ) ;   
 }   
   
 f u n c t i o n   o n w r i t e S t a t e U p d a t e ( s t a t e )   {   
     s t a t e . w r i t i n g   =   f a l s e ;   
     s t a t e . w r i t e c b   =   n u l l ;   
     s t a t e . l e n g t h   - =   s t a t e . w r i t e l e n ;   
     s t a t e . w r i t e l e n   =   0 ;   
 }   
   
 f u n c t i o n   o n w r i t e ( s t r e a m ,   e r )   {   
     v a r   s t a t e   =   s t r e a m . _ w r i t a b l e S t a t e ;   
     v a r   s y n c   =   s t a t e . s y n c ;   
     v a r   c b   =   s t a t e . w r i t e c b ;   
   
     o n w r i t e S t a t e U p d a t e ( s t a t e ) ;   
   
     i f   ( e r )   
         o n w r i t e E r r o r ( s t r e a m ,   s t a t e ,   s y n c ,   e r ,   c b ) ;   
     e l s e   {   
         / /   C h e c k   i f   w e ' r e   a c t u a l l y   r e a d y   t o   f i n i s h ,   b u t   d o n ' t   e m i t   y e t   
         v a r   f i n i s h e d   =   n e e d F i n i s h ( s t a t e ) ;   
   
         i f   ( ! f i n i s h e d   & &   
                 ! s t a t e . c o r k e d   & &   
                 ! s t a t e . b u f f e r P r o c e s s i n g   & &   
                 s t a t e . b u f f e r e d R e q u e s t )   {   
             c l e a r B u f f e r ( s t r e a m ,   s t a t e ) ;   
         }   
   
         i f   ( s y n c )   {   
             p r o c e s s . n e x t T i c k ( a f t e r W r i t e ,   s t r e a m ,   s t a t e ,   f i n i s h e d ,   c b ) ;   
         }   e l s e   {   
             a f t e r W r i t e ( s t r e a m ,   s t a t e ,   f i n i s h e d ,   c b ) ;   
         }   
     }   
 }   
   
 f u n c t i o n   a f t e r W r i t e ( s t r e a m ,   s t a t e ,   f i n i s h e d ,   c b )   {   
     i f   ( ! f i n i s h e d )   
         o n w r i t e D r a i n ( s t r e a m ,   s t a t e ) ;   
     s t a t e . p e n d i n g c b - - ;   
     c b ( ) ;   
     f i n i s h M a y b e ( s t r e a m ,   s t a t e ) ;   
 }   
   
 / /   M u s t   f o r c e   c a l l b a c k   t o   b e   c a l l e d   o n   n e x t T i c k ,   s o   t h a t   w e   d o n ' t   
 / /   e m i t   ' d r a i n '   b e f o r e   t h e   w r i t e ( )   c o n s u m e r   g e t s   t h e   ' f a l s e '   r e t u r n   
 / /   v a l u e ,   a n d   h a s   a   c h a n c e   t o   a t t a c h   a   ' d r a i n '   l i s t e n e r .   
 f u n c t i o n   o n w r i t e D r a i n ( s t r e a m ,   s t a t e )   {   
     i f   ( s t a t e . l e n g t h   = = =   0   & &   s t a t e . n e e d D r a i n )   {   
         s t a t e . n e e d D r a i n   =   f a l s e ;   
         s t r e a m . e m i t ( ' d r a i n ' ) ;   
     }   
 }   
   
 / /   i f   t h e r e ' s   s o m e t h i n g   i n   t h e   b u f f e r   w a i t i n g ,   t h e n   p r o c e s s   i t   
 f u n c t i o n   c l e a r B u f f e r ( s t r e a m ,   s t a t e )   {   
     s t a t e . b u f f e r P r o c e s s i n g   =   t r u e ;   
     v a r   e n t r y   =   s t a t e . b u f f e r e d R e q u e s t ;   
   
     i f   ( s t r e a m . _ w r i t e v   & &   e n t r y   & &   e n t r y . n e x t )   {   
         / /   F a s t   c a s e ,   w r i t e   e v e r y t h i n g   u s i n g   _ w r i t e v ( )   
         v a r   l   =   s t a t e . b u f f e r e d R e q u e s t C o u n t ;   
         v a r   b u f f e r   =   n e w   A r r a y ( l ) ;   
         v a r   h o l d e r   =   s t a t e . c o r k e d R e q u e s t s F r e e ;   
         h o l d e r . e n t r y   =   e n t r y ;   
   
         v a r   c o u n t   =   0 ;   
         w h i l e   ( e n t r y )   {   
             b u f f e r [ c o u n t ]   =   e n t r y ;   
             e n t r y   =   e n t r y . n e x t ;   
             c o u n t   + =   1 ;   
         }   
   
         d o W r i t e ( s t r e a m ,   s t a t e ,   t r u e ,   s t a t e . l e n g t h ,   b u f f e r ,   ' ' ,   h o l d e r . f i n i s h ) ;   
   
         / /   d o W r i t e   i s   a l m o s t   a l w a y s   a s y n c ,   d e f e r   t h e s e   t o   s a v e   a   b i t   o f   t i m e   
         / /   a s   t h e   h o t   p a t h   e n d s   w i t h   d o W r i t e   
         s t a t e . p e n d i n g c b + + ;   
         s t a t e . l a s t B u f f e r e d R e q u e s t   =   n u l l ;   
         i f   ( h o l d e r . n e x t )   {   
             s t a t e . c o r k e d R e q u e s t s F r e e   =   h o l d e r . n e x t ;   
             h o l d e r . n e x t   =   n u l l ;   
         }   e l s e   {   
             s t a t e . c o r k e d R e q u e s t s F r e e   =   n e w   C o r k e d R e q u e s t ( s t a t e ) ;   
         }   
     }   e l s e   {   
         / /   S l o w   c a s e ,   w r i t e   c h u n k s   o n e - b y - o n e   
         w h i l e   ( e n t r y )   {   
             v a r   c h u n k   =   e n t r y . c h u n k ;   
             v a r   e n c o d i n g   =   e n t r y . e n c o d i n g ;   
             v a r   c b   =   e n t r y . c a l l b a c k ;   
             v a r   l e n   =   s t a t e . o b j e c t M o d e   ?   1   :   c h u n k . l e n g t h ;   
   
             d o W r i t e ( s t r e a m ,   s t a t e ,   f a l s e ,   l e n ,   c h u n k ,   e n c o d i n g ,   c b ) ;   
             e n t r y   =   e n t r y . n e x t ;   
             / /   i f   w e   d i d n ' t   c a l l   t h e   o n w r i t e   i m m e d i a t e l y ,   t h e n   
             / /   i t   m e a n s   t h a t   w e   n e e d   t o   w a i t   u n t i l   i t   d o e s .   
             / /   a l s o ,   t h a t   m e a n s   t h a t   t h e   c h u n k   a n d   c b   a r e   c u r r e n t l y   
             / /   b e i n g   p r o c e s s e d ,   s o   m o v e   t h e   b u f f e r   c o u n t e r   p a s t   t h e m .   
             i f   ( s t a t e . w r i t i n g )   {   
                 b r e a k ;   
             }   
         }   
   
         i f   ( e n t r y   = = =   n u l l )   
             s t a t e . l a s t B u f f e r e d R e q u e s t   =   n u l l ;   
     }   
   
     s t a t e . b u f f e r e d R e q u e s t C o u n t   =   0 ;   
     s t a t e . b u f f e r e d R e q u e s t   =   e n t r y ;   
     s t a t e . b u f f e r P r o c e s s i n g   =   f a l s e ;   
 }   
   
 W r i t a b l e . p r o t o t y p e . _ w r i t e   =   f u n c t i o n ( c h u n k ,   e n c o d i n g ,   c b )   {   
     c b ( n e w   E r r o r ( ' _ w r i t e ( )   m e t h o d   i s   n o t   i m p l e m e n t e d ' ) ) ;   
 } ;   
   
 W r i t a b l e . p r o t o t y p e . _ w r i t e v   =   n u l l ;   
   
 W r i t a b l e . p r o t o t y p e . e n d   =   f u n c t i o n ( c h u n k ,   e n c o d i n g ,   c b )   {   
     v a r   s t a t e   =   t h i s . _ w r i t a b l e S t a t e ;   
   
     i f   ( t y p e o f   c h u n k   = = =   ' f u n c t i o n ' )   {   
         c b   =   c h u n k ;   
         c h u n k   =   n u l l ;   
         e n c o d i n g   =   n u l l ;   
     }   e l s e   i f   ( t y p e o f   e n c o d i n g   = = =   ' f u n c t i o n ' )   {   
         c b   =   e n c o d i n g ;   
         e n c o d i n g   =   n u l l ;   
     }   
   
     i f   ( c h u n k   ! = =   n u l l   & &   c h u n k   ! = =   u n d e f i n e d )   
         t h i s . w r i t e ( c h u n k ,   e n c o d i n g ) ;   
   
     / /   . e n d ( )   f u l l y   u n c o r k s   
     i f   ( s t a t e . c o r k e d )   {   
         s t a t e . c o r k e d   =   1 ;   
         t h i s . u n c o r k ( ) ;   
     }   
   
     / /   i g n o r e   u n n e c e s s a r y   e n d ( )   c a l l s .   
     i f   ( ! s t a t e . e n d i n g   & &   ! s t a t e . f i n i s h e d )   
         e n d W r i t a b l e ( t h i s ,   s t a t e ,   c b ) ;   
 } ;   
   
   
 f u n c t i o n   n e e d F i n i s h ( s t a t e )   {   
     r e t u r n   ( s t a t e . e n d i n g   & &   
                     s t a t e . l e n g t h   = = =   0   & &   
                     s t a t e . b u f f e r e d R e q u e s t   = = =   n u l l   & &   
                     ! s t a t e . f i n i s h e d   & &   
                     ! s t a t e . w r i t i n g ) ;   
 }   
   
 f u n c t i o n   p r e f i n i s h ( s t r e a m ,   s t a t e )   {   
     i f   ( ! s t a t e . p r e f i n i s h e d )   {   
         s t a t e . p r e f i n i s h e d   =   t r u e ;   
         s t r e a m . e m i t ( ' p r e f i n i s h ' ) ;   
     }   
 }   
   
 f u n c t i o n   f i n i s h M a y b e ( s t r e a m ,   s t a t e )   {   
     v a r   n e e d   =   n e e d F i n i s h ( s t a t e ) ;   
     i f   ( n e e d )   {   
         i f   ( s t a t e . p e n d i n g c b   = = =   0 )   {   
             p r e f i n i s h ( s t r e a m ,   s t a t e ) ;   
             s t a t e . f i n i s h e d   =   t r u e ;   
             s t r e a m . e m i t ( ' f i n i s h ' ) ;   
         }   e l s e   {   
             p r e f i n i s h ( s t r e a m ,   s t a t e ) ;   
         }   
     }   
     r e t u r n   n e e d ;   
 }   
   
 f u n c t i o n   e n d W r i t a b l e ( s t r e a m ,   s t a t e ,   c b )   {   
     s t a t e . e n d i n g   =   t r u e ;   
     f i n i s h M a y b e ( s t r e a m ,   s t a t e ) ;   
     i f   ( c b )   {   
         i f   ( s t a t e . f i n i s h e d )   
             p r o c e s s . n e x t T i c k ( c b ) ;   
         e l s e   
             s t r e a m . o n c e ( ' f i n i s h ' ,   c b ) ;   
     }   
     s t a t e . e n d e d   =   t r u e ;   
     s t r e a m . w r i t a b l e   =   f a l s e ;   
 }   
   
 / /   I t   s e e m s   a   l i n k e d   l i s t   b u t   i t   i s   n o t   
 / /   t h e r e   w i l l   b e   o n l y   2   o f   t h e s e   f o r   e a c h   s t r e a m   
 f u n c t i o n   C o r k e d R e q u e s t ( s t a t e )   {   
     t h i s . n e x t   =   n u l l ;   
     t h i s . e n t r y   =   n u l l ;   
   
     t h i s . f i n i s h   =   ( e r r )   = >   {   
         v a r   e n t r y   =   t h i s . e n t r y ;   
         t h i s . e n t r y   =   n u l l ;   
         w h i l e   ( e n t r y )   {   
             v a r   c b   =   e n t r y . c a l l b a c k ;   
             s t a t e . p e n d i n g c b - - ;   
             c b ( e r r ) ;   
             e n t r y   =   e n t r y . n e x t ;   
         }   
         i f   ( s t a t e . c o r k e d R e q u e s t s F r e e )   {   
             s t a t e . c o r k e d R e q u e s t s F r e e . n e x t   =   t h i s ;   
         }   e l s e   {   
             s t a t e . c o r k e d R e q u e s t s F r e e   =   t h i s ;   
         }   
     } ;   
 }   
 
 } ) ;   �;  0   ��
 S Y N O D E . J S       0	        / *   T h i s   S o u r c e   C o d e   F o r m   i s   s u b j e c t   t o   t h e   t e r m s   o f   t h e   M o z i l l a   P u b l i c   
   *   L i c e n s e ,   v .   2 . 0 .   I f   a   c o p y   o f   t h e   M P L   w a s   n o t   d i s t r i b u t e d   w i t h   t h i s   
   *   f i l e ,   Y o u   c a n   o b t a i n   o n e   a t   h t t p : / / m o z i l l a . o r g / M P L / 2 . 0 / .     
 * /   
   
 c o n s t   { c o r e M o d u l e s P a t h ,   r u n I n T h i s C o n t e x t ,   r u n I n T h i s C o n t e x t R e s ,   _ c o r e M o d u l e s I n R e s }   =   p r o c e s s . b i n d i n g ( ' m o d u l e s ' ) ;   
 c o n s t   { l o a d F i l e }   =   p r o c e s s . b i n d i n g ( ' f s ' ) ;   
 l e t   M o d u l e ;   
   
   
 / * *   
 *   @ n a m e s p a c e   p r o c e s s   
 *   @ p r o p e r t y   { s t r i n g }   s t a r t u p P a t h   U s e   a   p r o c e s s . c w d ( )   i n s t e a d   
 *   @ p r o p e r t y   { s t r i n g }   e x e c P a t h   T h e   m a i n   e x e c u t a b l e   f u l l   p a t h   ( i n c l u d i n g   . e x e   f i l e   n a m e )   
 * /   
   
 f u n c t i o n   s t a r t u p ( )   {   
         / * *   
           *   C u r r e n t   w o r k i n g   d i r e c t o r y   
           *   @ r e t u r n   { s t r i n g | S t r i n g }   
           * /   
         p r o c e s s . c w d   =   f u n c t i o n   ( )   {   
                 r e t u r n   p r o c e s s . s t a r t u p P a t h ;   
         } ;   
         / * *   
           *   L i s t   o f   l o a d e d   v i a   ` r e q u i r e `   m o d u l e s   
           *   @ p r i v a t e   
           *   @ t y p e   { A r r a y < s t r i n g > }   
           * /   
         p r o c e s s . m o d u l e L o a d L i s t   =   [ ] ;   
   
         M o d u l e   =   N a t i v e M o d u l e . r e q u i r e ( ' m o d u l e ' ) ;   
         M o d u l e . c a l l ( g l o b a l ,   [ ' . ' ] ) ;   
         p r o c e s s . m a i n M o d u l e   =   g l o b a l ;   
   
 / / n o i n s p e c t i o n   J S U n d e c l a r e d V a r i a b l e   
         / * *   
           *   L o a d   a   m o d u l e .   A c t s   l i k e   a   < a   h r e f = " h t t p : / / n o d e j s . o r g / a p i / m o d u l e s . h t m l " > N o d e   J S < / a >   r e q u i r e ,   w i t h   1   d i f f e r e n c e :   
           *   
           *       -   i n   c a s e   w e   r u n   i n   p r o d u c t i o n   m o d e   ( ` ! p r o c e s s . i s D e b u g ` )   a n d   m i n i m i z e d   v e r s i o n   o f   m a i n   m o d u l e   e x i s t s ,   i t   w i l l   b e   l o a d e d .   
           *           B y   " m i n i m i z e d   v e r s i o n "   w e   m e a n   p a c k a g e . j s o n   ` m a i n `   e n t r y   w i t h   ` . m i n . j s `   e x t e n s i o n   < b r >   
           *   
           *     * I n   c a s e   y o u   n e e d   t o   d e b u g   f r o m   t h e r e   m o d u l e   i s   l o a d e d   s e t   O S   E n v i r o n m e n t   v a r i a b l e *   
           *     ` > S E T   N O D E _ D E B U G = m o d u l e s `   * a n d   r e s t a r t   s e r v e r   -   r e q u i r e   w i l l   p u t   t o   d e b u g   l o g   a l l   i n f o r m a t i o n   a b o u t   h o w   m o d u l e   a r e   l o a d e d . *   D o   n o t   d o   t h i s   o n   p r o d u c t i o n ,   o f   c o u r s e   : )   
           *   
           *   @ g l o b a l   
           *   @ m e t h o d   
           *   @ p a r a m   { S t r i n g }   m o d u l e N a m e   
           *   @ r e t u r n s   { * }   
           * /   
         g l o b a l . r e q u i r e   =   M o d u l e . p r o t o t y p e . r e q u i r e ;   
         g l o b a l . B u f f e r   =   N a t i v e M o d u l e . r e q u i r e ( ' b u f f e r ' ) . B u f f e r ;   
         / / g l o b a l . c l e a r T i m e o u t   =   f u n c t i o n ( )   { } ;   
   
         / * *   
           *   B l o c k   t h r e a d   f o r   a   s p e c i f i e d   n u m b e r   o f   m i l l i s e c o n d s   
           *   @ p a r a m   { N u m b e r }   m s   m i l l i s e c o n d   t o   s l e e p   
           *   @ g l o b a l 	   
           * /   
         g l o b a l . s l e e p   =   p r o c e s s . b i n d i n g ( ' s y N o d e ' ) . s l e e p ;   
   
         c o n s t   E v e n t E m i t t e r   =   N a t i v e M o d u l e . r e q u i r e ( ' e v e n t s ' ) . E v e n t E m i t t e r ;   
         / /   a d d   E v e n t E m i t t e r   t o   p r o c e s s   o b j e c t   
         E v e n t E m i t t e r . c a l l ( p r o c e s s ) ;   
         O b j e c t . a s s i g n ( p r o c e s s ,   E v e n t E m i t t e r . p r o t o t y p e ) ;   
   
         c o n s t   W i n d o w T i m e r   =     N a t i v e M o d u l e . r e q u i r e ( ' p o l y f i l l / W i n d o w T i m e r ' ) ;   
         g l o b a l . _ t i m e r L o o p   =   W i n d o w T i m e r . m a k e W i n d o w T i m e r ( g l o b a l ,   f u n c t i o n   ( m s )   {   g l o b a l . s l e e p ( m s ) ;   } ) ;   
         / * *   
           *   T h i s   f u n c t i o n   i s   j u s t   t o   b e   c o m p a t i b l e   w i t h   n o d e . j s   
           *   @ p a r a m   { F u n c t i o n }   c a l l b a c k   C a l l b a c k   ( c a l l e d   i m m e d i a t e l y   i n   S y N o d e )   
           * /   
         p r o c e s s . n e x t T i c k   =   f u n c t i o n ( c a l l b a c k ,   a r g 1 ,   a r g 2 ,   a r g 3 ) {   
 	 	 i f   ( t y p e o f   c a l l b a c k   ! = =   ' f u n c t i o n ' )   {   
 	 	 	 t h r o w   n e w   T y p e E r r o r ( ' " c a l l b a c k "   a r g u m e n t   m u s t   b e   a   f u n c t i o n ' ) ;   
 	 	 }   
                 / /   o n   t h e   w a y   o u t ,   d o n ' t   b o t h e r .   i t   w o n ' t   g e t   f i r e d   a n y w a y .   
                 i f   ( p r o c e s s . _ e x i t i n g )   
                         r e t u r n ;   
   
                 v a r   i ,   a r g s ;   
   
 	 	 s w i t c h   ( a r g u m e n t s . l e n g t h )   {   
 	 	 / /   f a s t   c a s e s   
 	 	 c a s e   1 :   
 	 	     b r e a k ;   
 	 	 c a s e   2 :   
 	 	     a r g s   =   [ a r g 1 ] ;   
 	 	     b r e a k ;   
 	 	 c a s e   3 :   
 	 	     a r g s   =   [ a r g 1 ,   a r g 2 ] ;   
 	 	     b r e a k ;   
 	 	 d e f a u l t :   
 	 	     a r g s   =   [ a r g 1 ,   a r g 2 ,   a r g 3 ] ;   
 	 	     f o r   ( i   =   4 ;   i   <   a r g u m e n t s . l e n g t h ;   i + + )   
 	 	 	 a r g s [ i   -   1 ]   =   a r g u m e n t s [ i ] ;   
 	 	     b r e a k ;   
 	 	 }   
                 g l o b a l . _ t i m e r L o o p . s e t T i m e o u t W i t h P r i o r i t y . a p p l y ( u n d e f i n e d ,   [ c a l l b a c k ,   0 ,   - 1 ] . c o n c a t ( a r g s ) ) ;   
         } ;   
   
         / * *   
           *   T h i s   f u n c t i o n   i s     t o   b e   c o m p a t i b l e   w i t h   n o d e . j s   
           *   @ g l o b a l 	 	   
           *   @ p a r a m   { F u n c t i o n }   c a l l b a c k   
           *   @ p a r a m   { . . . * }   a r g   
           *   @ r e t u r n   { N u m b e r }   i m m e d i a t e I d 	   
           * /   
         g l o b a l . s e t I m m e d i a t e   =   f u n c t i o n ( c a l l b a c k ,   a r g 1 ,   a r g 2 ,   a r g 3 ) {   
 	     i f   ( t y p e o f   c a l l b a c k   ! = =   ' f u n c t i o n ' )   {   
 	 	 t h r o w   n e w   T y p e E r r o r ( ' " c a l l b a c k "   a r g u m e n t   m u s t   b e   a   f u n c t i o n ' ) ;   
 	     }   
             / /   o n   t h e   w a y   o u t ,   d o n ' t   b o t h e r .   i t   w o n ' t   g e t   f i r e d   a n y w a y .   
             i f   ( p r o c e s s . _ e x i t i n g )   
                     r e t u r n ;   
   
 	     v a r   i ,   a r g s ;   
   
 	     s w i t c h   ( a r g u m e n t s . l e n g t h )   {   
 	 	 / /   f a s t   c a s e s   
 	 	 c a s e   1 :   
 	 	     b r e a k ;   
 	 	 c a s e   2 :   
 	 	     a r g s   =   [ a r g 1 ] ;   
 	 	     b r e a k ;   
 	 	 c a s e   3 :   
 	 	     a r g s   =   [ a r g 1 ,   a r g 2 ] ;   
 	 	     b r e a k ;   
 	 	 d e f a u l t :   
 	 	     a r g s   =   [ a r g 1 ,   a r g 2 ,   a r g 3 ] ;   
 	 	     f o r   ( i   =   4 ;   i   <   a r g u m e n t s . l e n g t h ;   i + + )   
 	 	 	 a r g s [ i   -   1 ]   =   a r g u m e n t s [ i ] ;   
 	 	     b r e a k ;   
 	     }   
             g l o b a l . _ t i m e r L o o p . s e t T i m e o u t W i t h P r i o r i t y . a p p l y ( u n d e f i n e d ,   [ c a l l b a c k ,   0 ,   1 ] . c o n c a t ( a r g s ) ) ;   
         } ;   
   
 }   
   
   
 f u n c t i o n   N a t i v e M o d u l e ( i d )   {   
         t h i s . f i l e n a m e   =   i d   +   ' . j s ' ;   
         t h i s . i d   =   i d ;   
         t h i s . e x p o r t s   =   { } ;   
         t h i s . l o a d e d   =   f a l s e ;   
 }   
   
 c o n s t   N O D E _ C O R E _ M O D U L E S   =   [ ' f s ' ,   ' u t i l ' ,   ' p a t h ' ,   ' a s s e r t ' ,   ' m o d u l e ' ,   ' c o n s o l e ' ,   ' e v e n t s ' , ' v m ' ,   
   ' n e t ' ,   ' o s ' ,   ' p u n y c o d e ' ,   ' q u e r y s t r i n g ' ,   ' t i m e r s ' ,   ' t t y ' ,   ' u r l ' ,   ' c h i l d _ p r o c e s s ' ,   ' h t t p ' ,   ' h t t p s ' ,   
   ' c r y p t o ' ,   ' z l i b ' ,   ' d n s ' ,   / / f a k e   m o d u l e s   
   ' b u f f e r ' ,   ' s t r i n g _ d e c o d e r ' ,   ' i n t e r n a l / u t i l ' ,   ' i n t e r n a l / m o d u l e ' ,   ' s t r e a m ' ,   ' _ s t r e a m _ r e a d a b l e ' ,   ' _ s t r e a m _ w r i t a b l e ' ,     
   ' i n t e r n a l / s t r e a m s / B u f f e r L i s t ' ,   ' _ s t r e a m _ d u p l e x ' ,   ' _ s t r e a m _ t r a n s f o r m ' ,   ' _ s t r e a m _ p a s s t h r o u g h ' ,   
   ' i n t e r n a l / f s ' ,   
   ' i n t e r n a l / e r r o r s ' ,   ' i n t e r n a l / q u e r y s t r i n g ' ,       
   ' p o l y f i l l / W i n d o w T i m e r ' ] ;     
   
 N a t i v e M o d u l e . _ s o u r c e   =   { } ;   
 c o n s t   P A T H _ D E L I M   =   p r o c e s s . p l a t f o r m   = = =   ' w i n 3 2 '   ?   ' \ \ '   :   ' / '   
 N O D E _ C O R E _ M O D U L E S . f o r E a c h (   ( m o d u l e _ n a m e )   = >   {     
     N a t i v e M o d u l e . _ s o u r c e [ m o d u l e _ n a m e ]   =   _ c o r e M o d u l e s I n R e s   
             ?   ` n o d e _ m o d u l e s / $ { m o d u l e _ n a m e } . j s ` . t o U p p e r C a s e ( )   
             :   ` $ { c o r e M o d u l e s P a t h } $ { P A T H _ D E L I M } n o d e _ m o d u l e s $ { P A T H _ D E L I M } $ { m o d u l e _ n a m e } . j s `   
 } ) ;   
   
 N a t i v e M o d u l e . _ c a c h e   =   { } ;   
   
 N a t i v e M o d u l e . r e q u i r e   =   f u n c t i o n   ( i d )   {   
         i f   ( i d   = =   ' n a t i v e _ m o d u l e ' )   {   
                 r e t u r n   N a t i v e M o d u l e ;   
         }   
   
         v a r   c a c h e d   =   N a t i v e M o d u l e . g e t C a c h e d ( i d ) ;   
         i f   ( c a c h e d )   {   
                 r e t u r n   c a c h e d . e x p o r t s ;   
         }   
   
         i f   ( ! N a t i v e M o d u l e . e x i s t s ( i d ) )   {   
                 t h r o w   n e w   E r r o r ( ' N o   s u c h   n a t i v e   m o d u l e   '   +   i d ) ;   
         }   
   
         p r o c e s s . m o d u l e L o a d L i s t . p u s h ( ' N a t i v e M o d u l e   '   +   i d ) ;   
   
         v a r   n a t i v e M o d u l e   =   n e w   N a t i v e M o d u l e ( i d ) ;   
   
         n a t i v e M o d u l e . c a c h e ( ) ;   
         n a t i v e M o d u l e . c o m p i l e ( ) ;   
   
         r e t u r n   n a t i v e M o d u l e . e x p o r t s ;   
 } ;   
   
 N a t i v e M o d u l e . g e t C a c h e d   =   f u n c t i o n   ( i d )   {   
         i f   ( N a t i v e M o d u l e . _ c a c h e . h a s O w n P r o p e r t y ( i d ) )   {   
                 r e t u r n   N a t i v e M o d u l e . _ c a c h e [ i d ]   
         }   e l s e   {   
                 r e t u r n   n u l l ;   
         }   
 } ;   
   
 N a t i v e M o d u l e . e x i s t s   =   f u n c t i o n   ( i d )   {   
         r e t u r n   N a t i v e M o d u l e . _ s o u r c e . h a s O w n P r o p e r t y ( i d ) ;   
 } ;   
   
 c o n s t   E X P O S E _ I N T E R N A L S   =   f a l s e ;   
 / *   M P V   
 c o n s t   E X P O S E _ I N T E R N A L S   =   p r o c e s s . e x e c A r g v . s o m e ( f u n c t i o n ( a r g )   {   
         r e t u r n   a r g . m a t c h ( / ^ - - e x p o s e [ - _ ] i n t e r n a l s $ / ) ;   
     } ) ;   
 * /   
     i f   ( E X P O S E _ I N T E R N A L S )   {   
         N a t i v e M o d u l e . n o n I n t e r n a l E x i s t s   =   N a t i v e M o d u l e . e x i s t s ;   
   
         N a t i v e M o d u l e . i s I n t e r n a l   =   f u n c t i o n ( i d )   {   
             r e t u r n   f a l s e ;   
         } ;   
     }   e l s e   {   
         N a t i v e M o d u l e . n o n I n t e r n a l E x i s t s   =   f u n c t i o n ( i d )   {   
             r e t u r n   N a t i v e M o d u l e . e x i s t s ( i d )   & &   ! N a t i v e M o d u l e . i s I n t e r n a l ( i d ) ;   
         } ;   
   
         N a t i v e M o d u l e . i s I n t e r n a l   =   f u n c t i o n ( i d )   {   
             r e t u r n   i d . s t a r t s W i t h ( ' i n t e r n a l / ' ) ;   
         } ;   
     }   
   
 N a t i v e M o d u l e . g e t S o u r c e   =   f u n c t i o n   ( i d )   {   
         r e t u r n   l o a d F i l e ( N a t i v e M o d u l e . _ s o u r c e [ i d ] ) ;   
 } ;   
   
 N a t i v e M o d u l e . w r a p   =   f u n c t i o n   ( s c r i p t )   {   
         r e t u r n   N a t i v e M o d u l e . w r a p p e r [ 0 ]   +   s c r i p t   +   N a t i v e M o d u l e . w r a p p e r [ 1 ] ;   
 } ;   
   
 N a t i v e M o d u l e . w r a p p e r   =   [   
         ' ( f u n c t i o n   ( e x p o r t s ,   r e q u i r e ,   m o d u l e ,   _ _ f i l e n a m e ,   _ _ d i r n a m e )   {   ' ,   ' \ n } ) ; '   
 ] ;   
   
 N a t i v e M o d u l e . p r o t o t y p e . c o m p i l e   =   f u n c t i o n   ( )   {   
         l e t   f n ;   
         i f   ( _ c o r e M o d u l e s I n R e s )   {   
                 f n   =   r u n I n T h i s C o n t e x t R e s ( N a t i v e M o d u l e . _ s o u r c e [ t h i s . i d ] ,   t h i s . f i l e n a m e ,   t r u e ) ;   
         }   e l s e   {   
                 l e t   s o u r c e   =   N a t i v e M o d u l e . g e t S o u r c e ( t h i s . i d ) ;   
                 s o u r c e   =   N a t i v e M o d u l e . w r a p ( s o u r c e ) ;   
                 f n   =   r u n I n T h i s C o n t e x t ( s o u r c e ,   t h i s . f i l e n a m e ,   t r u e ) ;   
         }   
         f n ( t h i s . e x p o r t s ,   N a t i v e M o d u l e . r e q u i r e ,   t h i s ,   t h i s . f i l e n a m e ) ;   
         t h i s . l o a d e d   =   t r u e ;   
 } ;   
   
 N a t i v e M o d u l e . p r o t o t y p e . c a c h e   =   f u n c t i o n   ( )   {   
         N a t i v e M o d u l e . _ c a c h e [ t h i s . i d ]   =   t h i s ;   
 } ;   
   
 s t a r t u p ( ) ;   
 / / / p a t c h   M o d u l e L o a d e r   