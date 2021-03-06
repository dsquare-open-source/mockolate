package mockolate.issues
{
	import flash.utils.flash_proxy;
	
	import mockolate.expect;
	import mockolate.received;
	import mockolate.runner.MockolateRule;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.hamcrest.Description;
	import org.hamcrest.Matcher;
	import org.hamcrest.StringDescription;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.isTrue;
	
	use namespace flash_proxy;
	use namespace test_namespace;

	public class Issue21_NamespaceSupport_UsingRecordReplayTest
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(namespaces="mockolate.issues.test_namespace")]
		public var instance:Issue21_NamespaceSupport_ClassWithNamespace;
		
		[Test]
		public function recordReplay_shouldInterceptNamespacedMethod():void 
		{
			expect(instance.test_namespace::methodInNamespace()).returns(true);
			
			assertThat(instance.test_namespace::methodInNamespace(), isTrue());
			assertThat(instance, received().nsMethod(test_namespace, "methodInNamespace"));
		}
		
		[Test]
		public function recordReplay_shouldInterceptNamespacedGetter():void 
		{
			expect(instance.test_namespace::testGetter).returns(true);
			
			assertThat(instance.test_namespace::testGetter, isTrue());
			assertThat(instance, received().nsGetter(test_namespace, "testGetter"));
		}
		
		[Test]
		public function recordReplay_shouldInterceptNamespacedSetter():void 
		{
			expect(instance.test_namespace::testSetter = true);
			
			instance.test_namespace::testSetter = true;
			
			assertThat(instance, received().nsSetter(test_namespace, "testSetter"));
		}
		
		[Test(verify="false")]
		public function recordReplay_nsMethod_withoutInvocation_shouldHaveNiceErrorMessage():void 
		{
			expect(instance.test_namespace::methodInNamespace()).returns(true);
			
			assertMismatch("mockolate.issues::Issue21_NamespaceSupport_ClassWithNamespace(instance).methodInNamespace() invoked 0/1 (-1) times", 
				received().nsMethod(test_namespace, "methodInNamespace"), 
				instance); 

			// this truncates the error message in the flexunit results panel.
//			assertThat(instance, received().nsMethod(test_namespace, "methodInNamespace").anyArgs());
		}
		
		[Test(verify="false")]
		public function recordReplay_nsGetter_withoutInvocation_shouldHaveNiceErrorMessage():void 
		{
			expect(instance.test_namespace::testGetter).returns(true);
			
			assertMismatch("mockolate.issues::Issue21_NamespaceSupport_ClassWithNamespace(instance).testGetter; invoked 0/1 (-1) times", 
				received().nsGetter(test_namespace, "testGetter"),
				instance);
			
//			assertThat(instance, received().nsGetter(test_namespace, "testGetter"));			
		}
		
		[Test(verify="false")]
		public function recordReplay_nsSetter_withoutInvocation_shouldHaveNiceErrorMessage():void 
		{
			expect(instance.test_namespace::testSetter = true);
	
			assertMismatch("mockolate.issues::Issue21_NamespaceSupport_ClassWithNamespace(instance).testSetter = ?; invoked 0/1 (-1) times", 
				received().nsSetter(test_namespace, "testSetter"),
				instance);
			
//			assertThat(instance, received().nsSetter(test_namespace, "testSetter"));			
		}
		
		// borrowed from org.hamcrest.AbstractMatcherTestCase
		public function assertMismatch(expected:String, matcher:Matcher, arg:Object):void
		{
			assertFalse("Precondition: Matcher should not match item.", matcher.matches(arg));
			
			var description:Description = new StringDescription();            
			description.appendMismatchOf(matcher, arg);
			assertEquals("Expected mismatch description", expected, description.toString());
		}
	}
}