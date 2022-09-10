#include "Model.as"

shared class ActorModel : Model
{
	ModelSegment@ body;
	ModelSegment@ head;
	ModelSegment@ upperLeftArm;
	ModelSegment@ lowerLeftArm;
	ModelSegment@ upperRightArm;
	ModelSegment@ lowerRightArm;
	ModelSegment@ upperLeftLeg;
	ModelSegment@ lowerLeftLeg;
	ModelSegment@ upperRightLeg;
	ModelSegment@ lowerRightLeg;

	ActorModel(string texture, float scale = 1.0f)
	{
		@body = ModelSegment("ActorBody.obj", texture);
		@head = ModelSegment("ActorHead.obj", texture);
		@upperLeftArm = ModelSegment("ActorUpperLeftArm.obj", texture);
		@lowerLeftArm = ModelSegment("ActorLowerLeftArm.obj", texture);
		@upperRightArm = ModelSegment("ActorUpperRightArm.obj", texture);
		@lowerRightArm = ModelSegment("ActorLowerRightArm.obj", texture);
		@upperLeftLeg = ModelSegment("ActorUpperLeftLeg.obj", texture);
		@lowerLeftLeg = ModelSegment("ActorLowerLeftLeg.obj", texture);
		@upperRightLeg = ModelSegment("ActorUpperRightLeg.obj", texture);
		@lowerRightLeg = ModelSegment("ActorLowerRightLeg.obj", texture);

		body.AddChild(head);
		body.AddChild(upperLeftArm);
		body.AddChild(upperRightArm);
		body.AddChild(upperLeftLeg);
		body.AddChild(upperRightLeg);

		upperLeftArm.AddChild(lowerLeftArm);
		upperRightArm.AddChild(lowerRightArm);
		upperLeftLeg.AddChild(lowerLeftLeg);
		upperRightLeg.AddChild(lowerRightLeg);

		body.initialOffset = Vec3f(0, 0.75f, 0);
		head.initialOffset = Vec3f(0, 0.75f, 0);
		upperLeftArm.initialOffset = Vec3f(-0.25f, 0.75f, 0);
		lowerLeftArm.initialOffset = Vec3f(-0.125f, -0.375f, -0.125f);
		upperRightArm.initialOffset = Vec3f(0.25f, 0.75f, 0);
		lowerRightArm.initialOffset = Vec3f(0.125f, -0.375f, -0.125f);
		lowerLeftLeg.initialOffset = Vec3f(-0.125f, -0.375f, 0.125f);
		lowerRightLeg.initialOffset = Vec3f(0.125f, -0.375f, 0.125f);

		super(body, scale);
	}
}
